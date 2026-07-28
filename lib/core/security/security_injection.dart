import 'package:get_it/get_it.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_repository.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_repository_impl.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_secure_store.dart';
import 'package:isi_group_corporate_app/core/security/biometric/biometric_service.dart';
import 'package:isi_group_corporate_app/core/security/biometric/device_settings_launcher.dart';
import 'package:isi_group_corporate_app/core/security/biometric/identity_verification_cache.dart';

/// Registers `core/security/` infrastructure.
///
/// Called from `initDependencies()` **before** any feature registration:
/// Authentication and Profile both resolve [BiometricRepository], and
/// `ENGINEERING_STANDARD.md` §5 requires core infrastructure to be registered
/// once in `core/di/` and injected into features — features never construct
/// their own instances.
///
/// One object graph. There is exactly one [BiometricRepository] in the app, so
/// the Profile settings screen and the login gate can never disagree about
/// whether biometrics are enabled.
void registerSecurityInfrastructure(GetIt sl) {
  // The plugin is constructed inside LocalAuthBiometricService, which is the
  // only file allowed to import `package:local_auth` — so this composition
  // root never names a plugin type.
  sl.registerLazySingleton<BiometricService>(LocalAuthBiometricService.new);

  // Secure storage only. The FlutterSecureStorage singleton is registered by
  // the core composition root before this runs.
  sl.registerLazySingleton<BiometricSecureStore>(
    () => BiometricSecureStoreImpl(sl()),
  );

  sl.registerLazySingleton<BiometricRepository>(
    () => BiometricRepositoryImpl(service: sl(), store: sl()),
  );

  sl.registerLazySingleton<DeviceSettingsLauncher>(
    DeviceSettingsLauncherImpl.new,
  );

  // Singleton on purpose: the grace window is shared across every guarded
  // screen, so verifying once to open Payslips also covers Performance and
  // Leave for the next minute. A factory would give each screen its own
  // window, which would defeat the point.
  sl.registerLazySingleton<IdentityVerificationCache>(
    IdentityVerificationCache.new,
  );
}
