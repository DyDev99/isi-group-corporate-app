import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isi_group_corporate_app/core/localization/localization_services.dart';
import 'package:isi_group_corporate_app/core/security/biometric/authentication_reason.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_failure.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_result.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_service.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_type.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/bloc/biometric/biometric_bloc.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/bloc/biometric/biometric_event.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/bloc/biometric/biometric_state.dart';
import 'package:isi_group_corporate_app/shared/widgets/biometric/biometric_dialogs.dart';
import 'package:isi_group_corporate_app/shared/widgets/biometric/biometric_enrollment_screen.dart';
import 'package:isi_group_corporate_app/shared/widgets/biometric/biometric_setup_screen.dart';

/// Builds the already-localized strings the OS renders inside its own prompt.
///
/// Native dialogs cannot be styled or translated by Flutter at draw time — the
/// strings must be handed over resolved. This is the one place that happens,
/// so every prompt in the app is consistently translated.
BiometricPromptCopy buildPromptCopy(AuthenticationReason reason) =>
    BiometricPromptCopy(
      reason: reason.localizationKey.tr,
      signInTitle: reason.titleKey.tr,
      cancelButton: 'common.cancel'.tr,
      goToSettingsButton: 'auth.biometric.enrollment.open_settings'.tr,
      goToSettingsDescription: 'auth.biometric.enrollment.body'.tr,
      biometricRequiredTitle: 'auth.biometric.prompt.required_title'.tr,
      deviceCredentialsRequiredTitle:
          'auth.biometric.prompt.credentials_required_title'.tr,
    );

/// Runs the five-step biometric onboarding as a full-screen modal route.
///
/// ## Contract
///
/// Resolves to `true` only when the user completed **every** step and the OS
/// returned a positive match; `false` on cancel, failure or an unsupported
/// device. Callers use the result purely for messaging — the switch itself
/// renders from persisted settings, so even a caller that ignores the result
/// cannot leave a switch enabled that should not be.
///
/// ## Reusability
///
/// Takes a [BiometricBloc] and a [BiometricModality] and nothing else. Login,
/// Profile, payment confirmation and document unlock all use this same flow;
/// only the [AuthenticationReason] behind the prompt copy differs.
class BiometricOnboardingFlow extends StatefulWidget {
  const BiometricOnboardingFlow({
    super.key,
    required this.modality,
    this.reason = AuthenticationReason.enableBiometric,
  });

  final BiometricModality modality;
  final AuthenticationReason reason;

  /// Pushes the flow over [context]. The [BiometricBloc] is passed down
  /// explicitly because the new route sits outside the caller's provider
  /// subtree.
  static Future<bool> start(
    BuildContext context, {
    required BiometricBloc bloc,
    required BiometricModality modality,
    AuthenticationReason reason = AuthenticationReason.enableBiometric,
  }) async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => BlocProvider<BiometricBloc>.value(
          value: bloc,
          child: BiometricOnboardingFlow(modality: modality, reason: reason),
        ),
      ),
    );
    return completed ?? false;
  }

  @override
  State<BiometricOnboardingFlow> createState() =>
      _BiometricOnboardingFlowState();
}

class _BiometricOnboardingFlowState extends State<BiometricOnboardingFlow>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Step 3 depends on noticing that the user came back from device settings.
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<BiometricBloc>()
          .add(BiometricEnableRequested(modality: widget.modality));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // "Automatically check biometric availability again" on return. The bloc
    // ignores this unless the flow is actually sitting on the enrolment step,
    // so an unrelated resume costs nothing.
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<BiometricBloc>().add(const BiometricEnrollmentRechecked());
    }
  }

  void _cancel() {
    context.read<BiometricBloc>().add(const BiometricOnboardingCancelled());
    Navigator.of(context).maybePop(false);
  }

  void _verify() {
    context.read<BiometricBloc>().add(
        BiometricVerificationRequested(copy: buildPromptCopy(widget.reason)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BiometricBloc, BiometricState>(
      listenWhen: (previous, current) => previous.step != current.step,
      listener: (context, state) {
        // Step 2 resolves to "ready" → raise the native prompt immediately;
        // the user should not have to press a second button to reach the OS.
        if (state.step == BiometricFlowStep.verifying && !state.isBusy) {
          _verify();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.03),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey(state.step),
              child: _stepView(context, state),
            ),
          ),
        );
      },
    );
  }

  Widget _stepView(BuildContext context, BiometricState state) {
    final modality = state.pendingModality ?? widget.modality;

    return switch (state.step) {
      BiometricFlowStep.idle ||
      BiometricFlowStep.welcome =>
        BiometricSetupScreen(
          modality: modality,
          onContinue: () => context
              .read<BiometricBloc>()
              .add(const BiometricOnboardingContinued()),
          onCancel: _cancel,
        ),

      // Step 2 is a brief probe; a spinner reads better than a screen that
      // flashes past.
      BiometricFlowStep.validating => _Validating(
          message: 'auth.biometric.validating'.tr,
        ),
      BiometricFlowStep.enrollmentRequired => BiometricEnrollmentScreen(
          modality: modality,
          status:
              state.enrollmentStatus ?? BiometricEnrollmentStatus.notEnrolled,
          canOpenSettings:
              context.read<BiometricBloc>().canDeepLinkToEnrollment,
          isBusy: state.isBusy,
          onOpenSettings: () => context
              .read<BiometricBloc>()
              .add(const BiometricEnrollmentSettingsRequested()),
          onCancel: _cancel,
        ),
      BiometricFlowStep.verifying => BiometricVerificationDialog(
          modality: modality,
          isBusy: state.isBusy,
          onRetry: _verify,
          onCancel: _cancel,
        ),
      BiometricFlowStep.success => BiometricSuccessDialog(
          modality: modality,
          onDone: () {
            context.read<BiometricBloc>().add(const BiometricFlowDismissed());
            Navigator.of(context).maybePop(true);
          },
        ),
      BiometricFlowStep.unsupported => BiometricUnsupportedDialog(
          code: state.failureCode ?? BiometricFailureCode.noHardware,
          onDismiss: _cancel,
        ),
      BiometricFlowStep.error => BiometricErrorDialog(
          code: state.failureCode ?? BiometricFailureCode.unknown,
          onRetry: _verify,
          onOpenSettings: () => context
              .read<BiometricBloc>()
              .add(const BiometricEnrollmentSettingsRequested()),
          onDismiss: _cancel,
        ),
    };
  }
}

class _Validating extends StatelessWidget {
  const _Validating({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(strokeWidth: 2.6),
          const SizedBox(height: 24),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
