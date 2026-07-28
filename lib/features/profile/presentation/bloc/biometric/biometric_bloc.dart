import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isi_group_corporate_app/core/error/failures.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_failure.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_result.dart';
import 'package:isi_group_corporate_app/core/security/biometric/device_settings_launcher.dart';
import 'package:isi_group_corporate_app/core/usecase/usecase.dart';
import 'package:isi_group_corporate_app/features/profile/domain/usecases/biometric_usecases.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/bloc/biometric/biometric_event.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/bloc/biometric/biometric_state.dart';

/// Owns the biometric onboarding state machine.
///
/// ## The rule this bloc exists to enforce
///
/// A switch turns ON **only** after the full sequence completes:
///
/// ```text
/// EnableRequested → welcome → validating ─┬─ noHardware ──→ unsupported (switch stays OFF)
///                                          ├─ notEnrolled ─→ enrollmentRequired ─┐
///                                          └─ ready ───────→ verifying           │
///                                                              │                 │
///                                          ┌───────────────────┘   (user enrols, │
///                                          │                        returns) ────┘
///                                    OS verdict
///                                    ├─ match  → enable() → success (switch ON)
///                                    └─ refuse → error   (switch stays OFF)
/// ```
///
/// The switch never reads a local flag — it reads
/// `state.settings.biometricType`, which is only written by the repository
/// after a positive OS match. There is deliberately no code path from
/// [BiometricEnableRequested] to a persisted `enabled: true` that skips
/// verification.
///
/// Cancelling or failing at any step leaves the persisted settings untouched,
/// so the switch falls back to OFF on the next rebuild. "Partially enabled" is
/// not a representable state.
class BiometricBloc extends Bloc<BiometricEvent, BiometricState> {
  BiometricBloc({
    required CheckBiometricCapabilityUseCase checkCapability,
    required CheckEnrollmentUseCase checkEnrollment,
    required AuthenticateBiometricUseCase authenticate,
    required EnableBiometricUseCase enable,
    required DisableBiometricUseCase disable,
    required GetBiometricSettingsUseCase getSettings,
    required DeviceSettingsLauncher settingsLauncher,
  })  : _checkCapability = checkCapability,
        _checkEnrollment = checkEnrollment,
        _authenticate = authenticate,
        _enable = enable,
        _disable = disable,
        _getSettings = getSettings,
        _settingsLauncher = settingsLauncher,
        super(const BiometricState()) {
    on<BiometricStarted>(_onStarted);
    on<BiometricEnableRequested>(_onEnableRequested);
    on<BiometricOnboardingContinued>(_onContinued);
    on<BiometricEnrollmentSettingsRequested>(_onOpenSettings);
    on<BiometricEnrollmentRechecked>(_onRecheckEnrollment);
    // `droppable`: the OS permits exactly one prompt at a time; a queued second
    // request surfaces as `auth_in_progress`.
    on<BiometricVerificationRequested>(_onVerify, transformer: droppable());
    on<BiometricOnboardingCancelled>(_onCancelled);
    on<BiometricDisableRequested>(_onDisableRequested);
    on<BiometricFlowDismissed>(_onDismissed);
  }

  final CheckBiometricCapabilityUseCase _checkCapability;
  final CheckEnrollmentUseCase _checkEnrollment;
  final AuthenticateBiometricUseCase _authenticate;
  final EnableBiometricUseCase _enable;
  final DisableBiometricUseCase _disable;
  final GetBiometricSettingsUseCase _getSettings;
  final DeviceSettingsLauncher _settingsLauncher;

  /// Whether the platform can deep-link to enrolment (Android) or the user
  /// must be given written directions (iOS). Read by the enrolment screen.
  bool get canDeepLinkToEnrollment => _settingsLauncher.canDeepLinkToEnrollment;

  // ── Load ────────────────────────────────────────────────────────────

  Future<void> _onStarted(
    BiometricStarted event,
    Emitter<BiometricState> emit,
  ) async {
    emit(state.copyWith(isBusy: true));

    final settingsResult = await _getSettings(const NoParams());
    final capabilityResult = await _checkCapability(const NoParams());

    // Both fail closed: an unreadable store or probe renders the switches OFF
    // and unsupported rather than optimistically ON.
    final settings = settingsResult.when(
      success: (s) => s,
      failure: (_) => state.settings,
    );
    final capability = capabilityResult.when(
      success: (c) => c,
      failure: (_) => const BiometricCapability.unsupported(
        BiometricFailureCode.unknown,
      ),
    );

    emit(state.copyWith(
      settings: settings,
      capability: capability,
      enrollmentStatus: BiometricEnrollmentStatus.fromCapability(capability),
      isBusy: false,
      step: BiometricFlowStep.idle,
    ));
  }

  // ── Step 1: welcome ─────────────────────────────────────────────────

  /// Flipping the switch ON starts the flow. It does **not** enable anything.
  Future<void> _onEnableRequested(
    BiometricEnableRequested event,
    Emitter<BiometricState> emit,
  ) async {
    emit(state.copyWith(
      step: BiometricFlowStep.welcome,
      pendingModality: event.modality,
      clearFailure: true,
    ));
  }

  // ── Step 2: device validation ───────────────────────────────────────

  Future<void> _onContinued(
    BiometricOnboardingContinued event,
    Emitter<BiometricState> emit,
  ) async {
    emit(state.copyWith(step: BiometricFlowStep.validating, isBusy: true));

    final result = await _checkCapability(const NoParams());
    final capability = result.when(
      success: (c) => c,
      failure: (_) =>
          const BiometricCapability.unsupported(BiometricFailureCode.unknown),
    );

    emit(state.copyWith(
      capability: capability,
      enrollmentStatus: BiometricEnrollmentStatus.fromCapability(capability),
      isBusy: false,
      step: _stepForCapability(capability),
      failureCode: capability.hasHardware
          ? null
          : capability.unsupportedReason ?? BiometricFailureCode.noHardware,
    ));
  }

  /// Routes Step 2's outcome. Three destinations, no fall-through to "enabled".
  BiometricFlowStep _stepForCapability(BiometricCapability capability) {
    if (!capability.hasHardware) return BiometricFlowStep.unsupported;
    if (capability.needsEnrollment) return BiometricFlowStep.enrollmentRequired;

    final modality = state.pendingModality;
    if (modality != null && !capability.supports(modality)) {
      // Hardware and *something* enrolled, but not this modality — e.g. the
      // user asked for Face ID on a fingerprint-only device.
      return BiometricFlowStep.enrollmentRequired;
    }
    return BiometricFlowStep.verifying;
  }

  // ── Step 3: device enrollment ───────────────────────────────────────

  Future<void> _onOpenSettings(
    BiometricEnrollmentSettingsRequested event,
    Emitter<BiometricState> emit,
  ) async {
    // Never throws by contract; a false result just means the written
    // instructions on screen are the user's path.
    await _settingsLauncher.openBiometricEnrollment();
  }

  /// Re-probes after the user comes back from device settings.
  ///
  /// If they enrolled, the flow advances to verification on its own. If they
  /// did not, it stays on the enrolment screen and the switch stays OFF —
  /// which is the explicit requirement.
  Future<void> _onRecheckEnrollment(
    BiometricEnrollmentRechecked event,
    Emitter<BiometricState> emit,
  ) async {
    if (state.step != BiometricFlowStep.enrollmentRequired) return;

    emit(state.copyWith(isBusy: true));
    final result = await _checkCapability(const NoParams());
    final capability = result.when(
      success: (c) => c,
      failure: (_) =>
          const BiometricCapability.unsupported(BiometricFailureCode.unknown),
    );

    final enrollment = await _checkEnrollment(const NoParams());

    emit(state.copyWith(
      capability: capability,
      enrollmentStatus: enrollment.when(
        success: (s) => s,
        failure: (_) => BiometricEnrollmentStatus.fromCapability(capability),
      ),
      isBusy: false,
      step: _stepForCapability(capability),
    ));
  }

  // ── Step 4 + 5: verify, then persist ────────────────────────────────

  Future<void> _onVerify(
    BiometricVerificationRequested event,
    Emitter<BiometricState> emit,
  ) async {
    final modality = state.pendingModality;
    if (modality == null) return;

    emit(state.copyWith(
      step: BiometricFlowStep.verifying,
      isBusy: true,
      clearFailure: true,
    ));

    final verdict = await _authenticate(
      AuthenticateBiometricParams(copy: event.copy),
    );

    final matched = verdict.when(success: (v) => v, failure: (_) => false);
    if (!matched) {
      // Failure keeps the switch OFF and offers retry. Nothing was persisted.
      emit(state.copyWith(
        step: BiometricFlowStep.error,
        isBusy: false,
        failureCode: verdict.when(
          success: (_) => BiometricFailureCode.unknown,
          failure: _codeOf,
        ),
      ));
      return;
    }

    // Only here — after a positive OS match — is anything written.
    final enabled = await _enable(BiometricModalityParams(modality: modality));

    emit(enabled.when(
      success: (settings) => state.copyWith(
        settings: settings,
        step: BiometricFlowStep.success,
        isBusy: false,
        clearFailure: true,
      ),
      failure: (f) => state.copyWith(
        step: BiometricFlowStep.error,
        isBusy: false,
        failureCode: _codeOf(f),
      ),
    ));
  }

  // ── Cancel / disable / dismiss ──────────────────────────────────────

  /// Abandoning the flow persists nothing, so the switch reverts to OFF.
  Future<void> _onCancelled(
    BiometricOnboardingCancelled event,
    Emitter<BiometricState> emit,
  ) async {
    emit(state.copyWith(
      step: BiometricFlowStep.idle,
      isBusy: false,
      clearPendingModality: true,
      clearFailure: true,
    ));
  }

  /// Disabling is immediate and unguarded — see [DisableBiometricUseCase].
  Future<void> _onDisableRequested(
    BiometricDisableRequested event,
    Emitter<BiometricState> emit,
  ) async {
    emit(state.copyWith(isBusy: true));
    final result = await _disable(
      BiometricModalityParams(modality: event.modality),
    );

    emit(result.when(
      success: (settings) => state.copyWith(
        settings: settings,
        isBusy: false,
        step: BiometricFlowStep.idle,
        clearPendingModality: true,
        clearFailure: true,
      ),
      failure: (f) => state.copyWith(
        isBusy: false,
        step: BiometricFlowStep.error,
        failureCode: _codeOf(f),
      ),
    ));
  }

  Future<void> _onDismissed(
    BiometricFlowDismissed event,
    Emitter<BiometricState> emit,
  ) async {
    emit(state.copyWith(
      step: BiometricFlowStep.idle,
      isBusy: false,
      clearPendingModality: true,
      clearFailure: true,
    ));
  }

  /// Extracts the normalised code from any failure. Non-biometric failures
  /// (e.g. a secure-storage write error) surface as `unknown` so presentation
  /// still has a localization key and never renders a raw message.
  BiometricFailureCode _codeOf(Failure failure) => switch (failure) {
        BiometricFailure(code: final code) => code,
        _ => BiometricFailureCode.unknown,
      };
}
