import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isi_group_corporate_app/core/localization/localization_services.dart';
import 'package:isi_group_corporate_app/core/security/biometric/authentication_reason.dart';
import 'package:isi_group_corporate_app/core/theme/theme_extensions.dart';
import 'package:isi_group_corporate_app/core/utils/colors.dart';
import 'package:isi_group_corporate_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:isi_group_corporate_app/features/authentication/presentation/bloc/auth_event.dart';
import 'package:isi_group_corporate_app/shared/widgets/biometric/biometric_onboarding_flow.dart';

/// The biometric affordance on the login form.
///
/// Deliberately a *secondary* control below the credential fields, not a
/// replacement for them: the form is always present and always submittable,
/// so this button can be hidden at any time (no sensor, nothing enrolled, no
/// stored session, not opted in) without leaving the screen unusable.
///
/// The caller decides visibility from the gate; this widget only dispatches.
class BiometricUnlockButton extends StatelessWidget {
  const BiometricUnlockButton({super.key, this.enabled = true});

  /// `false` while a request is already in flight.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppColors.radius),
          onTap: enabled
              ? () => context.read<AuthBloc>().add(
                    // Copy is resolved here, in presentation: the OS renders
                    // these strings verbatim and the domain holds no display
                    // text. `AuthenticationReason.login` selects the sign-in
                    // wording rather than a generic "Authenticate".
                    BiometricUnlockRequested(
                      copy: buildPromptCopy(AuthenticationReason.login),
                    ),
                  )
              : null,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppColors.radius),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.45)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fingerprint, size: 22, color: scheme.primary),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'auth.biometric.unlock_button'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: enabled ? scheme.primary : colors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
