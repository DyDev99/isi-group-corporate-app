import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:isi_group_corporate_app/core/middleware/app_middleware.dart';
import 'package:isi_group_corporate_app/core/network/app_network.dart';
import 'package:isi_group_corporate_app/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:isi_group_corporate_app/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:isi_group_corporate_app/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/authenticate_with_biometrics.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/can_offer_biometric_unlock.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/get_current_user.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/login.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/usecases/logout.dart';
import 'package:isi_group_corporate_app/features/authentication/presentation/bloc/auth_bloc.dart';

/// Registers every dependency the authentication feature needs.
/// Externals (secure storage, connectivity, network info) are registered
/// by the core composition root before this runs.
///
/// All registrations are lazy, so registration order is irrelevant — a
/// dependency is only built the first time it's resolved.
void registerAuthFeature(GetIt sl) {
  // ── Presentation ───────────────────────────────────────────────────
  // Factory: a fresh bloc per screen, disposed with it.
  sl.registerFactory(
    () => AuthBloc(
      login: sl(),
      logout: sl(),
      getCurrentUser: sl(),
      sessionManager: sl(),
      authenticateWithBiometrics: sl(),
      canOfferBiometricUnlock: sl(),
    ),
  );

  // ── Domain (use cases) ─────────────────────────────────────────────
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Biometric *login* only. Enabling/disabling lives in the Profile feature's
  // BiometricBloc — this feature can consume biometrics but cannot turn them
  // on. Both resolve the same core BiometricRepository, so there is one graph
  // and one source of truth.
  sl.registerLazySingleton(
    () => CanOfferBiometricUnlock(
      biometricRepository: sl(),
      authRepository: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => AuthenticateWithBiometrics(
      biometricRepository: sl(),
      canOffer: sl(),
      authRepository: sl(),
    ),
  );

  // ── Data (repository) ──────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl(), local: sl(), networkInfo: sl()),
  );

  // ── Data (sources) ─────────────────────────────────────────────────
  // One concrete local source, exposed under two interfaces so the
  // interceptor and the repository share the exact same token storage.
  sl.registerLazySingleton(() => AuthLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthLocalDataSource>(
      () => sl<AuthLocalDataSourceImpl>());
  sl.registerLazySingleton<TokenStore>(() => sl<AuthLocalDataSourceImpl>());

  // Authenticated Dio client (auto token attach + refresh).
  sl.registerLazySingleton<Dio>(
    () => AppNetwork.createAuthedClient(tokenStore: sl<TokenStore>()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<Dio>()),
  );
}
