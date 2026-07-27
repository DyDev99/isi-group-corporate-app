import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_repository.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_secure_store.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_service.dart';
import 'package:isi_group_corporate_app/core/security/biometric/device_settings_launcher.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/authenticate_with_biometrics.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/can_offer_biometric_unlock.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/get_current_user.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/login.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/logout.dart';
import 'package:isi_group_corporate_app/features/profile/domain/usecases/biometric_usecases.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';

/// Shared doubles for the biometric tests.
///
/// [MockLocalAuthentication] is the only place outside `biometric_service.dart`
/// that references `package:local_auth` — everything above the service is
/// tested against our own types, which is the point of the port.
class MockLocalAuthentication extends Mock implements LocalAuthentication {}

class MockBiometricService extends Mock implements BiometricService {}

class MockBiometricSecureStore extends Mock implements BiometricSecureStore {}

class MockBiometricRepository extends Mock implements BiometricRepository {}

class MockDeviceSettingsLauncher extends Mock
    implements DeviceSettingsLauncher {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockAuthRepository extends Mock implements AuthRepository {}

// ── Profile use cases ──────────────────────────────────────────────────
class MockCheckBiometricCapabilityUseCase extends Mock
    implements CheckBiometricCapabilityUseCase {}

class MockCheckEnrollmentUseCase extends Mock
    implements CheckEnrollmentUseCase {}

class MockAuthenticateBiometricUseCase extends Mock
    implements AuthenticateBiometricUseCase {}

class MockEnableBiometricUseCase extends Mock
    implements EnableBiometricUseCase {}

class MockDisableBiometricUseCase extends Mock
    implements DisableBiometricUseCase {}

class MockGetBiometricSettingsUseCase extends Mock
    implements GetBiometricSettingsUseCase {}

// ── Authentication use cases ───────────────────────────────────────────
class MockLogin extends Mock implements Login {}

class MockLogout extends Mock implements Logout {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockAuthenticateWithBiometrics extends Mock
    implements AuthenticateWithBiometrics {}

class MockCanOfferBiometricUnlock extends Mock
    implements CanOfferBiometricUnlock {}

/// Prompt copy for tests. Content is irrelevant to behaviour — the service
/// forwards it verbatim to the OS.
const testPromptCopy = BiometricPromptCopy(
  reason: 'Confirm it is you',
  signInTitle: 'Sign in',
  cancelButton: 'Cancel',
  goToSettingsButton: 'Settings',
  goToSettingsDescription: 'Enroll a biometric',
  biometricRequiredTitle: 'Biometric required',
  deviceCredentialsRequiredTitle: 'Device unlock required',
);
