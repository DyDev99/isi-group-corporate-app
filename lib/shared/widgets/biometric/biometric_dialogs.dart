import 'package:flutter/material.dart';
import 'package:isi_group_corporate_app/core/localization/localization_services.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_failure.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_type.dart';
import 'package:isi_group_corporate_app/core/theme/theme_extensions.dart';
import 'package:isi_group_corporate_app/shared/widgets/biometric/biometric_scaffold.dart';

/// **Step 4 — Verify Your Identity.**
///
/// Rendered *behind* the native OS prompt. It exists so that when the system
/// dialog is dismissed the user is not staring at the settings list wondering
/// what happened — there is a screen explaining what is being asked, with a
/// retry.
class BiometricVerificationDialog extends StatelessWidget {
  const BiometricVerificationDialog({
    super.key,
    required this.modality,
    required this.onRetry,
    required this.onCancel,
    this.isBusy = true,
  });

  final BiometricModality modality;
  final VoidCallback onRetry;
  final VoidCallback onCancel;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return BiometricScaffold(
      icon: modality == BiometricModality.face
          ? Icons.face_retouching_natural_rounded
          : Icons.fingerprint_rounded,
      title: 'auth.biometric.verify.title'.tr,
      body: 'auth.biometric.verify.body'
          .trParams({'modality': modality.labelKey.tr}),
      onClose: onCancel,
      isBusy: isBusy,
      extra: isBusy
          ? const Padding(
              padding: EdgeInsets.only(top: 4),
              child: LinearProgressIndicator(minHeight: 3),
            )
          : null,
      primaryLabel: 'auth.biometric.verify.retry'.tr,
      onPrimary: onRetry,
      secondaryLabel: 'common.cancel'.tr,
      onSecondary: onCancel,
    );
  }
}

/// **Step 5 — Success.**
///
/// The only screen in the flow that appears after the switch has actually been
/// turned on, which is what makes it a truthful confirmation rather than an
/// optimistic one.
class BiometricSuccessDialog extends StatelessWidget {
  const BiometricSuccessDialog({
    super.key,
    required this.modality,
    required this.onDone,
  });

  final BiometricModality modality;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BiometricScaffold(
      icon: Icons.verified_rounded,
      iconColor: colors.success,
      title: 'auth.biometric.success.title'.tr,
      body: 'auth.biometric.success.body'
          .trParams({'modality': modality.labelKey.tr}),
      showCloseButton: false,
      primaryLabel: 'common.done'.tr,
      onPrimary: onDone,
    );
  }
}

/// Terminal state for a device that can never do biometrics.
///
/// Deliberately not phrased as an error the user caused, and it always names
/// the alternative — the password still works, nothing is lost.
class BiometricUnsupportedDialog extends StatelessWidget {
  const BiometricUnsupportedDialog({
    super.key,
    required this.code,
    required this.onDismiss,
  });

  final BiometricFailureCode code;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BiometricScaffold(
      icon: Icons.no_encryption_gmailerrorred_rounded,
      iconColor: colors.textSecondary,
      title: 'auth.biometric.unsupported.title'.tr,
      body: code.localizationKey.tr,
      showCloseButton: false,
      extra: BiometricBullet(
        icon: Icons.password_rounded,
        label: 'auth.biometric.unsupported.fallback'.tr,
      ),
      primaryLabel: 'common.got_it'.tr,
      onPrimary: onDismiss,
    );
  }
}

/// Recoverable failure — cancellation, lockout, a non-match.
///
/// Offers Retry only when the code says retrying could plausibly work
/// ([BiometricFailureCode.isRetryable]), and routes to device settings when the
/// fix is an enrolment. The button set is derived from the taxonomy, never
/// from string-matching a message.
class BiometricErrorDialog extends StatelessWidget {
  const BiometricErrorDialog({
    super.key,
    required this.code,
    required this.onRetry,
    required this.onOpenSettings,
    required this.onDismiss,
  });

  final BiometricFailureCode code;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final needsEnrollment = code.requiresEnrollment;

    return BiometricScaffold(
      icon: code.requiresDeviceUnlock
          ? Icons.lock_clock_rounded
          : Icons.error_outline_rounded,
      iconColor: code.isUserDismissal ? colors.textSecondary : colors.warning,
      title: code.isUserDismissal
          ? 'auth.biometric.error.cancelled_title'.tr
          : 'auth.biometric.error.title'.tr,
      body: code.localizationKey.tr,
      onClose: onDismiss,
      extra: BiometricBullet(
        icon: Icons.password_rounded,
        label: 'auth.biometric.unsupported.fallback'.tr,
      ),
      primaryLabel: needsEnrollment
          ? 'auth.biometric.enrollment.open_settings'.tr
          : code.isRetryable
              ? 'auth.biometric.verify.retry'.tr
              : 'common.got_it'.tr,
      onPrimary: needsEnrollment
          ? onOpenSettings
          : code.isRetryable
              ? onRetry
              : onDismiss,
      secondaryLabel: 'common.cancel'.tr,
      onSecondary: onDismiss,
    );
  }
}
