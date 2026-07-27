import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isi_group_corporate_app/core/localization/localization_services.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_result.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_type.dart';
import 'package:isi_group_corporate_app/shared/widgets/biometric/biometric_scaffold.dart';

/// **Step 3 — Device enrollment.**
///
/// Shown when the device has biometric hardware but the user has not
/// registered a fingerprint or face (or has no screen lock).
///
/// The screen is explicit that Android and iOS own enrolment and that ISI
/// Corporate never sees biometric data — this is the moment the user is most
/// likely to wonder, and answering it here is what makes the flow feel like
/// the OS's own setup rather than an app asking for a fingerprint.
///
/// On Android the button deep-links to the enrolment screen. On iOS no public
/// deep link exists, so [canOpenSettings] is false, the button opens the app's
/// own settings page, and the numbered directions carry the user the rest of
/// the way.
class BiometricEnrollmentScreen extends StatelessWidget {
  const BiometricEnrollmentScreen({
    super.key,
    required this.modality,
    required this.status,
    required this.canOpenSettings,
    required this.onOpenSettings,
    required this.onCancel,
    this.isBusy = false,
    @visibleForTesting this.isIosOverride,
  });

  final BiometricModality modality;
  final BiometricEnrollmentStatus status;

  /// Whether the platform can navigate directly to biometric enrolment.
  final bool canOpenSettings;

  final VoidCallback onOpenSettings;
  final VoidCallback onCancel;
  final bool isBusy;

  /// Test seam — production reads [Platform.isIOS].
  final bool? isIosOverride;

  bool get _isIos =>
      isIosOverride ?? (!kIsWeb && Platform.isIOS);

  @override
  Widget build(BuildContext context) {
    // A missing screen lock is a different problem from a missing fingerprint,
    // and needs different instructions — the user must set a passcode first.
    final needsPasscode = status == BiometricEnrollmentStatus.deviceNotSecure;

    return BiometricScaffold(
      icon: needsPasscode
          ? Icons.lock_outline_rounded
          : Icons.settings_suggest_rounded,
      title: needsPasscode
          ? 'auth.biometric.enrollment.passcode_title'.tr
          : 'auth.biometric.enrollment.title'
              .trParams({'modality': modality.labelKey.tr}),
      body: needsPasscode
          ? 'auth.biometric.enrollment.passcode_body'.tr
          : 'auth.biometric.enrollment.body'.tr,
      onClose: onCancel,
      isBusy: isBusy,
      extra: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, instruction) in _instructions(needsPasscode)
              .indexed)
            BiometricInstruction(step: index + 1, label: instruction),
          const SizedBox(height: 12),
          BiometricBullet(
            icon: Icons.privacy_tip_outlined,
            label: 'auth.biometric.enrollment.privacy'.tr,
          ),
        ],
      ),
      primaryLabel: canOpenSettings
          ? 'auth.biometric.enrollment.open_settings'.tr
          : 'auth.biometric.enrollment.open_app_settings'.tr,
      onPrimary: onOpenSettings,
      secondaryLabel: 'common.cancel'.tr,
      onSecondary: onCancel,
    );
  }

  /// Platform-specific directions. iOS gets a full path because it cannot be
  /// deep-linked; Android gets a short confirmation of where the button lands.
  List<String> _instructions(bool needsPasscode) {
    if (needsPasscode) {
      return [
        _isIos
            ? 'auth.biometric.enrollment.ios_step_passcode'.tr
            : 'auth.biometric.enrollment.android_step_passcode'.tr,
        'auth.biometric.enrollment.step_return'.tr,
      ];
    }
    return _isIos
        ? [
            'auth.biometric.enrollment.ios_step_open'.tr,
            'auth.biometric.enrollment.ios_step_enroll'.tr,
            'auth.biometric.enrollment.step_return'.tr,
          ]
        : [
            'auth.biometric.enrollment.android_step_open'.tr,
            'auth.biometric.enrollment.android_step_enroll'.tr,
            'auth.biometric.enrollment.step_return'.tr,
          ];
  }
}
