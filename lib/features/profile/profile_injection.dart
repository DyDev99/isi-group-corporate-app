import 'package:get_it/get_it.dart';
import 'package:isi_group_corporate_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:isi_group_corporate_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:isi_group_corporate_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:isi_group_corporate_app/features/profile/domain/usecases/change_password.dart';
import 'package:isi_group_corporate_app/features/profile/domain/usecases/get_worker_profile.dart';
import 'package:isi_group_corporate_app/features/profile/domain/usecases/logout_worker.dart';
import 'package:isi_group_corporate_app/features/profile/domain/usecases/biometric_usecases.dart';
import 'package:isi_group_corporate_app/features/profile/domain/usecases/update_worker_profile.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/bloc/biometric/biometric_bloc.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/bloc/profile_cubit.dart';

/// Registers the profile feature: worker profile read/update, password
/// change, and logout. Mirrors `registerMyVisitsFeature`.
void registerProfileFeature(GetIt sl) {
  // ── Data sources ────────────────────────────────────────────────────
  sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => MockProfileRemoteDataSource());

  // ── Repositories ────────────────────────────────────────────────────
  sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(remoteDataSource: sl()));

  // ── Use cases ───────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetWorkerProfile(sl()));
  sl.registerLazySingleton(() => UpdateWorkerProfile(sl()));
  sl.registerLazySingleton(() => ChangePassword(sl()));
  sl.registerLazySingleton(() => LogoutWorker(sl()));

  // ── Biometric use cases ─────────────────────────────────────────────
  // All resolve the shared core BiometricRepository registered by
  // `registerSecurityInfrastructure` — features never construct their own
  // security infrastructure (`ENGINEERING_STANDARD.md` §5).
  sl.registerLazySingleton(() => CheckBiometricCapabilityUseCase(sl()));
  sl.registerLazySingleton(() => CheckEnrollmentUseCase(sl()));
  sl.registerLazySingleton(() => AuthenticateBiometricUseCase(sl()));
  sl.registerLazySingleton(() => EnableBiometricUseCase(sl()));
  sl.registerLazySingleton(() => DisableBiometricUseCase(sl()));
  sl.registerLazySingleton(() => GetBiometricSettingsUseCase(sl()));

  // ── Presentation ────────────────────────────────────────────────────
  sl.registerFactory(() => ProfileCubit(
        getWorkerProfile: sl(),
        updateWorkerProfile: sl(),
        changePassword: sl(),
        logoutWorker: sl(),
      ));

  // Factory: the onboarding flow is a short-lived, screen-scoped machine.
  sl.registerFactory(() => BiometricBloc(
        checkCapability: sl(),
        checkEnrollment: sl(),
        authenticate: sl(),
        enable: sl(),
        disable: sl(),
        getSettings: sl(),
        settingsLauncher: sl(),
      ));
}
