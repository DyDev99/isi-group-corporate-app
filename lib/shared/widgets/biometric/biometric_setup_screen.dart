import 'package:flutter/material.dart';
import 'package:isi_group_corporate_app/core/localization/localization_services.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_type.dart';
import 'package:isi_group_corporate_app/shared/widgets/biometric/biometric_scaffold.dart';

/// **Step 1 — Welcome.**
///
/// The value proposition, before anything is checked or enabled. Reusable by
/// any feature that wants to introduce biometrics: it takes a [modality] and
/// two callbacks, and knows nothing about Profile or Authentication.
class BiometricSetupScreen extends StatelessWidget {
  const BiometricSetupScreen({
    super.key,
    required this.modality,
    required this.onContinue,
    required this.onCancel,
  });

  final BiometricModality modality;
  final VoidCallback onContinue;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return BiometricScaffold(
      icon: modality == BiometricModality.face
          ? Icons.face_retouching_natural_rounded
          : Icons.fingerprint_rounded,
      title: 'auth.biometric.setup.title'.tr,
      body: 'auth.biometric.setup.body'
          .trParams({'modality': modality.labelKey.tr}),
      onClose: onCancel,
      extra: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BiometricBullet(
            icon: Icons.bolt_rounded,
            label: 'auth.biometric.setup.benefit_faster'.tr,
          ),
          BiometricBullet(
            icon: Icons.lock_open_rounded,
            label: 'auth.biometric.setup.benefit_unlock'.tr,
          ),
          BiometricBullet(
            icon: Icons.verified_user_rounded,
            label: 'auth.biometric.setup.benefit_confirm'.tr,
          ),
          BiometricBullet(
            icon: Icons.shield_rounded,
            label: 'auth.biometric.setup.benefit_security'.tr,
          ),
          const SizedBox(height: 8),
          // The privacy promise belongs on the first screen, not buried in a
          // policy document: it is the answer to the question this screen
          // provokes ("are you taking my fingerprint?").
          BiometricBullet(
            icon: Icons.privacy_tip_outlined,
            label: 'auth.biometric.privacy_notice'.tr,
          ),
        ],
      ),
      primaryLabel: 'common.continue'.tr,
      onPrimary: onContinue,
      secondaryLabel: 'common.cancel'.tr,
      onSecondary: onCancel,
    );
  }
}
