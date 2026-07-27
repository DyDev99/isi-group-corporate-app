import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isi_group_corporate_app/core/utils/version.dart';
import 'package:isi_group_corporate_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:isi_group_corporate_app/features/authentication/presentation/bloc/auth_event.dart';
import 'package:isi_group_corporate_app/features/authentication/presentation/bloc/auth_state.dart';
import 'package:isi_group_corporate_app/core/theme/theme_extensions.dart';
import 'package:isi_group_corporate_app/core/localization/localization_services.dart';
import 'package:isi_group_corporate_app/shared/widgets/aurora_background.dart';
import 'package:isi_group_corporate_app/shared/widgets/glass_card.dart';
import 'package:isi_group_corporate_app/features/authentication/presentation/widgets/login/gradient_button.dart';
import 'package:isi_group_corporate_app/features/authentication/presentation/widgets/forgot_password/identifier_field.dart';
import 'package:isi_group_corporate_app/core/security/biometric/authentication_reason.dart';
import 'package:isi_group_corporate_app/features/authentication/presentation/widgets/login/biometric_unlock_button.dart';
import 'package:isi_group_corporate_app/shared/widgets/biometric/biometric_onboarding_flow.dart';
import 'package:isi_group_corporate_app/features/authentication/presentation/widgets/login/status_pill.dart';
import 'package:isi_group_corporate_app/features/authentication/presentation/widgets/login/vibe_field.dart';
import 'package:isi_group_corporate_app/routes/app_routes.dart';

/// Gen-Z sign-in for KIC. Mobile-first single column: aurora canvas +
/// frosted card. Business logic is unchanged — same AuthBloc contract.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onRequestAccess, this.onForgotPassword});

  /// Wire these from the navigation layer (kept out of the widget so it
  /// stays small and decoupled from concrete routes).
  final VoidCallback? onRequestAccess;
  final VoidCallback? onForgotPassword;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierKey = GlobalKey<IdentifierFieldState>();
  final _password = TextEditingController();
  bool _obscure = true;

  /// One-shot latch: the biometric prompt is raised at most once
  /// automatically. After that it is the user's call via the button, so a
  /// cancelled prompt can never re-open itself in a loop.
  bool _autoPrompted = false;

  @override
  void initState() {
    super.initState();
    // If we arrived here with a held session (biometric unlock is on), offer
    // the prompt straight away rather than making the user reach for it.
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoPrompt());
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _autoPrompt() {
    if (!mounted || _autoPrompted) return;
    final state = context.read<AuthBloc>().state;
    if (state is! AuthBiometricLockedState || !state.canUseBiometrics) return;
    _autoPrompted = true;
    context.read<AuthBloc>().add(
          BiometricUnlockRequested(
            copy: buildPromptCopy(AuthenticationReason.login),
          ),
        );
  }

  void _submit() {
    // Both need to pass: the Form validates the password field, and the
    // identifier field validates itself separately since it isn't a plain
    // FormField (see identifier_field.dart for why).
    final formOk = _formKey.currentState?.validate() ?? false;
    final identifierOk = _identifierKey.currentState?.validate() ?? false;
    if (!formOk || !identifierOk) return;

    context.read<AuthBloc>().add(
          LoginSubmittedEvent(
            // NOTE: this still passes through the `email` param name on
            // LoginSubmittedEvent — it may hold an email OR a phone number
            // now. Rename this param to `identifier` in auth_event.dart if
            // the backend distinguishes the two, or route on
            // `_identifierKey.currentState!.mode` here if needed.
            email: _identifierKey.currentState!.value,
            password: _password.text,
          ),
        );
  }

  AuthVibeStatus _statusFor(AuthState s) {
    if (s is AuthLoadingState) return AuthVibeStatus.verifying;
    if (s is AuthFailureState) return AuthVibeStatus.error;
    if (s is AuthenticatedState) return AuthVibeStatus.success;
    // A failed/cancelled biometric attempt is surfaced on the same pill, with
    // the form still right below it — informative, never blocking.
    if (s is AuthBiometricLockedState && s.noticeKey != null) {
      return AuthVibeStatus.error;
    }
    return AuthVibeStatus.idle;
  }

  /// Copy for the status pill. Biometric states carry a localization *key*
  /// (the bloc never holds display text), so it is resolved here.
  String? _messageFor(AuthState s) => switch (s) {
        AuthFailureState(message: final m) => m,
        AuthBiometricLockedState(noticeKey: final k) => k?.tr,
        _ => null,
      };

  /// This screen owns its own post-login transition (no global auth listener).
  ///
  /// Deliberately does **not** offer to enable biometrics here. Enabling is a
  /// five-step onboarding flow with an OS verification step, and it has one
  /// home: Profile → Password & Security. A second, lighter entry point on the
  /// login screen would be a second way to reach a security control, and the
  /// two would drift.
  void _onAuthenticated() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(Static.main, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Navigation lives here (not in a global listener) so it only fires for
    // *this* screen: on a successful sign-in we clear the stack down to a fresh
    // authenticated shell, whether the user arrived from onboarding or from a
    // "Login Required" prompt over the shell.
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => curr is AuthenticatedState,
      listener: (context, state) => _onAuthenticated(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Stack(
          children: [
            const Positioned.fill(child: AuroraBackground()),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Centered Header Section (Logo, Title, Subtitle)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const _Brand(),
                                  const SizedBox(height: 28),
                                  Text(
                                    'auth.welcome_back'.tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'auth.sign_in_subtitle'.tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: context.appColors.textSecondary,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              GlassCard(child: _form()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Versioning signature aligned perfectly at the bottom edge
                  const VersionFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IdentifierField(
            key: _identifierKey,
            required: true,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          VibeField(
            controller: _password,
            label: 'auth.password'.tr,
            icon: Icons.lock_outline,
            obscure: _obscure,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            required: true,
            onSubmitted: (_) => _submit(),
            suffix: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: context.appColors.textSecondary,
                size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            validator: (v) => (v == null || v.length < 6)
                ? 'auth.password_too_short'.tr
                : null,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(Static.forgotPassword),
              child: Text('auth.forgot_password'.tr,
                  style: TextStyle(
                      color: context.appColors.info,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 6),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final status = _statusFor(state);
              // The gate is decided in the domain and carried on the state —
              // this widget only renders it, and the credential button above
              // is never conditional on it.
              final offerBiometrics =
                  state is AuthBiometricLockedState && state.canUseBiometrics;
              return Column(
                children: [
                  StatusPill(status: status, message: _messageFor(state)),
                  GradientButton(
                    label: "auth.lets_go".tr,
                    loading: status == AuthVibeStatus.verifying,
                    onPressed: _submit,
                  ),
                  if (offerBiometrics)
                    BiometricUnlockButton(
                      enabled: status != AuthVibeStatus.verifying,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Compact brand mark — replaces the old wide identity panel.
/// Centered large image logo brand identity.
class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        "assets/logos/isi_app_logo.png", // Replace with your actual image path
        width: 180, // Adjust width size as needed (e.g., 150-240)
        fit: BoxFit.contain,
      ),
    );
  }
}
