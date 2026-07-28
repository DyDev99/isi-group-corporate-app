import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:isi_group_corporate_app/core/auth/auth_guard.dart';
import 'package:isi_group_corporate_app/core/error/failures.dart';
import 'package:isi_group_corporate_app/core/localization/localization_services.dart';
import 'package:isi_group_corporate_app/core/security/biometric/authentication_reason.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_failure.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_repository.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_result.dart';
import 'package:isi_group_corporate_app/core/security/biometric/identity_verification_cache.dart';
import 'package:isi_group_corporate_app/core/session/session_manager.dart';
import 'package:isi_group_corporate_app/core/theme/theme_extensions.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/login.dart';
import 'package:isi_group_corporate_app/shared/widgets/biometric/biometric_onboarding_flow.dart';

/// Re-authentication gate for a screen holding sensitive data.
///
/// ## Why this wraps the screen instead of the navigation call
///
/// Payslips, performance reviews and leave records are each reachable from
/// several places (Profile, Hubs, the dashboard shortcut, the shell tab).
/// Gating at every call site means the gate is one forgotten `push` away from
/// being bypassed — the exact "inline check that drifts" anti-pattern in
/// `AI_ENGINEERING_PLAYBOOK.md` §12. Wrapping the screen makes the gate
/// unconditional: there is no route to the content that does not pass through
/// it.
///
/// ## What counts as proof — in strict order
///
/// 1. **Face ID / fingerprint.** Tried first, and raised automatically the
///    moment the screen opens. The prompt is biometric-only: the device
///    PIN/pattern is *not* accepted, because anyone who knows the phone's
///    unlock code would otherwise reach payslips and reviews.
/// 2. **ISI Corporate account password — the last option.** Offered when the
///    device has no sensor, when nothing is enrolled, after a lockout, or
///    whenever the user chooses it. Verified through the existing `Login` use
///    case against the signed-in user's email, so it reuses the real
///    SAP-bound credential path and stores nothing new.
///
/// The user is never trapped: the password route is always reachable, and
/// cancelling returns them to the previous screen rather than leaving them on
/// a blank guard.
///
/// Note this gate is independent of the biometric *sign-in* toggle in Password
/// & Security. That switch governs how the user signs in; this protects data
/// on an already-signed-in session, so it offers biometrics whenever the
/// device can do them.
class SensitiveScreenGuard extends StatefulWidget {
  const SensitiveScreenGuard({
    super.key,
    required this.child,
    required this.reason,
    required this.titleKey,
    required this.descriptionKey,
    this.alwaysReverify = false,
    this.repository,
    this.login,
    this.session,
    this.verificationCache,
  });

  /// Ignore the grace window and always demand a fresh check.
  ///
  /// Left `false` for *viewing* protected data, which is what the grace window
  /// exists to smooth. Set it `true` for an action that authorises something —
  /// releasing a payment, approving a SAP document — where "you proved it a
  /// minute ago" is not good enough.
  final bool alwaysReverify;

  /// The protected screen. Not built until identity is proven.
  final Widget child;

  final AuthenticationReason reason;

  /// Localization keys for the lock screen shown before entry.
  final String titleKey;
  final String descriptionKey;

  // Injectable seams for tests; production resolves from the service locator.
  final BiometricRepository? repository;
  final Login? login;
  final SessionManager? session;
  final IdentityVerificationCache? verificationCache;

  @override
  State<SensitiveScreenGuard> createState() => _SensitiveScreenGuardState();
}

class _SensitiveScreenGuardState extends State<SensitiveScreenGuard> {
  bool _unlocked = false;
  bool _busy = false;
  bool _autoPrompted = false;
  String? _noticeKey;

  /// Whether option 1 is on the table at all. False on a device with no
  /// sensor, nothing enrolled, or after a lockout that biometrics cannot
  /// clear — in which case the password becomes the primary action rather
  /// than a link under a button that can only fail.
  bool _biometricAvailable = false;

  /// The device probe has finished, so the layout can stop guessing.
  bool _capabilityResolved = false;

  /// No signed-in account, so neither option can work yet. Renders a "sign in
  /// required" state rather than popping the route out from under the user.
  bool _needsSignIn = false;

  BiometricRepository get _repository =>
      widget.repository ?? GetIt.instance<BiometricRepository>();
  Login get _login => widget.login ?? GetIt.instance<Login>();
  SessionManager get _session =>
      widget.session ?? GetIt.instance<SessionManager>();
  IdentityVerificationCache get _cache =>
      widget.verificationCache ?? GetIt.instance<IdentityVerificationCache>();

  @override
  void initState() {
    super.initState();
    // Probe, then go straight for option 1. Making the user tap "Unlock"
    // first is a pointless extra step when they just tapped the menu item.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_autoPrompted) {
        _autoPrompted = true;
        _start();
      }
    });
  }

  /// Resolves what this device can do, then routes to option 1 or option 2.
  Future<void> _start() async {
    // Neither option can work without a signed-in account: biometrics unlock
    // *a session*, and the password is verified against the session's email.
    // A guest gets the app's standard "Login Required" prompt instead of a
    // screen that silently bounces them back.
    final user = _session.currentUser;
    if (user == null) {
      setState(() {
        _needsSignIn = true;
        _capabilityResolved = true;
        _busy = false;
      });
      return;
    }

    // Recently proved who they are — let them straight through. This is what
    // stops Payslips → Performance → Leave from being three prompts in half a
    // minute. See [IdentityVerificationCache] for why the window is safe.
    if (!widget.alwaysReverify && _cache.isValidFor(user.id)) {
      setState(() {
        _unlocked = true;
        _busy = false;
      });
      return;
    }

    setState(() => _busy = true);

    final capability = await _repository.checkCapability();
    final canUseBiometrics =
        capability.when(success: (c) => c.isReady, failure: (_) => false);

    if (!mounted) return;
    setState(() {
      _biometricAvailable = canUseBiometrics;
      _capabilityResolved = true;
      _busy = false;
    });

    if (canUseBiometrics) {
      await _authenticateBiometric();
      return;
    }

    // No face or fingerprint to offer — say why, then skip to the last option
    // rather than raising a prompt that can only fail.
    final status = capability.when(
      success: BiometricEnrollmentStatus.fromCapability,
      failure: (_) => BiometricEnrollmentStatus.unavailable,
    );
    setState(() => _noticeKey = status.localizationKey);
    await _promptForPassword();
  }

  /// Option 1 — face / fingerprint.
  Future<void> _authenticateBiometric() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _noticeKey = null;
    });

    final result = await _repository.authenticate(
      copy: buildPromptCopy(widget.reason),
    );
    if (!mounted) return;

    final matched = result.when(success: (v) => v, failure: (_) => false);
    if (matched) {
      _startGraceWindow();
      setState(() {
        _unlocked = true;
        _busy = false;
      });
      return;
    }

    final code = result.when(
      success: (_) => BiometricFailureCode.unknown,
      failure: (f) =>
          f is BiometricFailure ? f.code : BiometricFailureCode.unknown,
    );

    setState(() {
      _busy = false;
      // A deliberate dismissal is not an error worth shouting about; the user
      // knows they cancelled.
      _noticeKey = code.isUserDismissal ? null : code.localizationKey;
      // Retrying a lockout or a missing enrolment cannot succeed, so stop
      // offering it as the primary action and promote the password instead.
      if (!code.isRetryable) _biometricAvailable = false;
    });

    // Nothing biometric will work here — take the user to the last option
    // rather than leaving them staring at a dead button.
    if (!code.isRetryable && !code.isUserDismissal) {
      await _promptForPassword();
    }
  }

  /// Option 2 — the account password, the last resort.
  Future<void> _promptForPassword() async {
    final email = _session.currentUser?.email;
    if (email == null) {
      // Lost the session mid-flow (token revoked, logout on another surface).
      setState(() => _needsSignIn = true);
      return;
    }

    final confirmed = await _PasswordConfirmSheet.show(
      context,
      email: email,
      login: _login,
    );
    if (!mounted) return;
    if (confirmed) {
      _startGraceWindow();
      setState(() => _unlocked = true);
    }
  }

  /// Opens the grace window after a *successful* check — biometric match or
  /// verified password, never a cancel or a failure.
  ///
  /// Skipped entirely for [SensitiveScreenGuard.alwaysReverify] surfaces, so
  /// authorising a payment can never seed a window that lets the next screen
  /// through unchecked.
  void _startGraceWindow() {
    if (widget.alwaysReverify) return;
    final user = _session.currentUser;
    if (user != null) _cache.recordSuccess(user.id);
  }

  /// Routes a guest through the app's single login gate (`AuthGuard` →
  /// `LoginRequiredDialog`), rather than this screen inventing a second one.
  ///
  /// If they come back signed in, the identity check restarts on its own.
  Future<void> _signIn() async {
    await AuthGuard.requireAuthentication(context);
    if (!mounted) return;

    if (_session.currentUser != null) {
      setState(() => _needsSignIn = false);
      await _start();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return widget.child;

    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colors.textPrimary, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          widget.titleKey.tr,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _needsSignIn
                            ? Icons.account_circle_outlined
                            : Icons.lock_outline_rounded,
                        size: 46,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    _needsSignIn
                        ? 'auth.login_required_title'.tr
                        : 'auth.biometric.gate.title'.tr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _needsSignIn
                        ? 'auth.biometric.gate.sign_in_body'.tr
                        : widget.descriptionKey.tr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                          height: 1.5,
                        ),
                  ),
                  if (_noticeKey != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.warning.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 18, color: colors.warning),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _noticeKey!.tr,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: colors.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // ── No account yet ────────────────────────────────────
                  // Neither identity option can work, so route through the
                  // app's single login gate instead.
                  if (_needsSignIn)
                    FilledButton.icon(
                      onPressed: _busy ? null : _signIn,
                      icon: const Icon(Icons.login_rounded, size: 20),
                      label: Text('auth.login_now'.tr),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    )

                  // ── Option 1: face / fingerprint ──────────────────────
                  // Shown only while it can actually succeed. A button that
                  // can only fail teaches users the app is broken.
                  else if (!_capabilityResolved || _biometricAvailable) ...[
                    FilledButton.icon(
                      onPressed: _busy ? null : _authenticateBiometric,
                      icon: _busy
                          ? const SizedBox.shrink()
                          : const Icon(Icons.fingerprint_rounded, size: 20),
                      label: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2.4),
                            )
                          : Text('auth.biometric.gate.unlock'.tr),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // ── Option 2 (last resort), kept secondary ──────────
                    TextButton(
                      onPressed: _busy ? null : _promptForPassword,
                      style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(
                        'auth.biometric.gate.use_password'.tr,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else
                    // Biometrics are off the table on this device, so the
                    // password becomes the primary action rather than a link
                    // hidden under a dead button.
                    FilledButton.icon(
                      onPressed: _busy ? null : _promptForPassword,
                      icon: const Icon(Icons.password_rounded, size: 20),
                      label: Text('auth.biometric.gate.use_password'.tr),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Password re-entry fallback.
///
/// Verifies through the existing [Login] use case rather than storing or
/// comparing anything locally — no password or hash is ever persisted by this
/// app (`SECURITY.md` §3).
class _PasswordConfirmSheet extends StatefulWidget {
  const _PasswordConfirmSheet({required this.email, required this.login});

  final String email;
  final Login login;

  static Future<bool> show(
    BuildContext context, {
    required String email,
    required Login login,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PasswordConfirmSheet(email: email, login: login),
    );
    return result ?? false;
  }

  @override
  State<_PasswordConfirmSheet> createState() => _PasswordConfirmSheetState();
}

class _PasswordConfirmSheetState extends State<_PasswordConfirmSheet> {
  final _controller = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_controller.text.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    final result = await widget.login(
      LoginParams(email: widget.email, password: _controller.text),
    );
    if (!mounted) return;

    result.when(
      success: (_) => Navigator.of(context).pop(true),
      failure: (f) => setState(() {
        _busy = false;
        // Typed failure message, never a raw exception.
        _error = f.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'auth.biometric.gate.password_title'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'auth.biometric.gate.password_body'.tr,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _controller,
              obscureText: true,
              autofocus: true,
              enabled: !_busy,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'auth.password'.tr,
                errorText: _error,
                filled: true,
                fillColor: colors.surfaceSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.border),
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : Text('auth.biometric.gate.confirm'.tr),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: _busy ? null : () => Navigator.of(context).pop(false),
              child: Text(
                'common.cancel'.tr,
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
