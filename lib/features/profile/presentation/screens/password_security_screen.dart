import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:isi_group_corporate_app/core/localization/localization_services.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_type.dart';
import 'package:isi_group_corporate_app/core/theme/theme_extensions.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/bloc/biometric/biometric_bloc.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/bloc/biometric/biometric_event.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/bloc/biometric/biometric_state.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/widgets/biometric_switch_tile.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/widgets/security_documents.dart';
import 'package:isi_group_corporate_app/shared/widgets/biometric/biometric_onboarding_flow.dart';

// ============================================================================
// PASSWORD, BIOMETRICS & SECURITY
// ============================================================================

/// Password & Security settings.
///
/// ## The security rule this screen enforces
///
/// The biometric switches are **not** local widget state. They render from
/// `BiometricState.settings`, which the repository only writes after the OS
/// has returned a positive biometric match. Turning a switch on dispatches
/// [BiometricEnableRequested], which opens the onboarding flow — it does not
/// enable anything. Cancel, fail, or leave mid-flow and the switch is still
/// off, because nothing was ever persisted.
///
/// This replaces the previous implementation, where `_fingerprintEnabled`
/// defaulted to `true` and `onChanged` wrote straight to `setState` — the app
/// claimed biometric protection it had never verified.
class SecurityPrivacyScreen extends StatelessWidget {
  const SecurityPrivacyScreen({super.key, this.bloc});

  /// Injectable for tests and for callers that already own a bloc.
  final BiometricBloc? bloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BiometricBloc>(
      create: (_) =>
          (bloc ?? GetIt.instance<BiometricBloc>())..add(const BiometricStarted()),
      child: const _SecurityPrivacyView(),
    );
  }
}

class _SecurityPrivacyView extends StatelessWidget {
  const _SecurityPrivacyView();

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'profile.security.title'.tr,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              // Keeps the settings column readable on tablets and unfolded
              // foldables instead of stretching tiles edge to edge.
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SecuritySectionLabel(
                    label: 'profile.security.section_auth',
                  ),
                  const SizedBox(height: 12),
                  _AuthenticationCard(scheme: scheme),
                  const SizedBox(height: 28),
                  SecuritySectionLabel(
                    label: 'profile.security.section_knowledge',
                    trailing: Text(
                      'profile.security.guide_count'.trParams(
                        {'count': securityKnowledgeDocs.length},
                      ),
                      style:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: scheme.primary,
                              ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SecurityKnowledgeList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Credentials + biometrics group.
class _AuthenticationCard extends StatelessWidget {
  const _AuthenticationCard({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocConsumer<BiometricBloc, BiometricState>(
      // Only react to a *persisted* change, so the confirmation snackbar can
      // never fire for a switch that did not actually change.
      listenWhen: (previous, current) =>
          previous.settings.biometricType != current.settings.biometricType,
      listener: (context, state) {
        final enabled = state.settings.biometricType.isNotEmpty;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                enabled
                    ? 'auth.biometric.enabled_confirmation'.tr
                    : 'auth.biometric.disabled_confirmation'.tr,
              ),
            ),
          );
      },
      builder: (context, state) {
        return SecurityCard(
          children: [
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.key_rounded, color: scheme.primary, size: 20),
              ),
              title: Text(
                'profile.security.change_password'.tr,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
              ),
              subtitle: Text(
                'profile.security.change_password_subtitle'.tr,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: colors.textSecondary),
              ),
              trailing: Icon(Icons.chevron_right_rounded,
                  color: colors.iconMuted),
              onTap: () => showChangePasswordSheet(context),
            ),
            Divider(height: 1, color: colors.divider),

            // ── Biometric switches ────────────────────────────────────
            // Rendered only when the device actually has a sensor: a
            // permanently dead control teaches users the app is broken.
            if (state.isDeviceCapable) ...[
              _BiometricTile(
                modality: BiometricModality.fingerprint,
                icon: Icons.fingerprint_rounded,
                iconColor: colors.success,
                state: state,
              ),
              Divider(height: 1, color: colors.divider),
              _BiometricTile(
                modality: BiometricModality.face,
                icon: Icons.face_retouching_natural_rounded,
                iconColor: colors.accentPurple,
                state: state,
              ),
              Divider(height: 1, color: colors.divider),
            ] else
              _UnsupportedNotice(state: state),

            // Two-factor is unchanged and unrelated to this work; it remains a
            // presentation-only placeholder until the backend supports it.
            // TODO(release-gate): 2FA toggle is not wired to any backend yet.
            _TwoFactorTile(scheme: scheme),
          ],
        );
      },
    );
  }
}

/// One biometric switch, wired to the onboarding flow.
class _BiometricTile extends StatelessWidget {
  const _BiometricTile({
    required this.modality,
    required this.icon,
    required this.iconColor,
    required this.state,
  });

  final BiometricModality modality;
  final IconData icon;
  final Color iconColor;
  final BiometricState state;

  @override
  Widget build(BuildContext context) {
    final supported = state.isSupported(modality);
    final needsEnrollment = state.needsEnrollment;

    return BiometricSwitchTile(
      icon: icon,
      iconColor: iconColor,
      title: 'profile.security.${modality.name}_title'.tr,
      subtitle: 'profile.security.${modality.name}_subtitle'.tr,
      // The single source of truth: persisted settings, never local state.
      value: state.isEnabled(modality),
      // Still tappable when nothing is enrolled — tapping starts the flow,
      // which routes to enrolment guidance. Only a device that can never
      // support the modality gets a disabled control.
      enabled: !state.isBusy && (supported || needsEnrollment),
      unavailableNote: supported || needsEnrollment
          ? null
          : 'profile.security.modality_unavailable'.tr,
      onChanged: (wantsOn) => _onChanged(context, wantsOn: wantsOn),
    );
  }

  Future<void> _onChanged(
    BuildContext context, {
    required bool wantsOn,
  }) async {
    final bloc = context.read<BiometricBloc>();

    if (!wantsOn) {
      bloc.add(BiometricDisableRequested(modality: modality));
      return;
    }

    // Turning ON never writes anything here. It opens the flow; the flow's
    // Step 5 is the only thing that can persist an enabled state.
    await BiometricOnboardingFlow.start(
      context,
      bloc: bloc,
      modality: modality,
    );
  }
}

/// Shown instead of the switches when the device has no biometric hardware.
class _UnsupportedNotice extends StatelessWidget {
  const _UnsupportedNotice({required this.state});

  final BiometricState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: colors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'profile.security.no_biometric_hardware'.tr,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colors.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _TwoFactorTile extends StatefulWidget {
  const _TwoFactorTile({required this.scheme});

  final ColorScheme scheme;

  @override
  State<_TwoFactorTile> createState() => _TwoFactorTileState();
}

class _TwoFactorTileState extends State<_TwoFactorTile> {
  bool _enabled = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BiometricSwitchTile(
      icon: Icons.phonelink_lock_rounded,
      iconColor: colors.warningAlt,
      title: 'profile.security.two_factor_title'.tr,
      subtitle: 'profile.security.two_factor_subtitle'.tr,
      value: _enabled,
      onChanged: (value) => setState(() => _enabled = value),
    );
  }
}
