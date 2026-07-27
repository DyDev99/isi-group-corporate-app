import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:isi_group_corporate_app/core/config/env.dart';
import 'package:isi_group_corporate_app/core/database/drift/app_database.dart';
import 'package:isi_group_corporate_app/core/database/drift/app_database_rekey_executor.dart';
import 'package:isi_group_corporate_app/core/database/secure/app_database_key_provider.dart';
import 'package:isi_group_corporate_app/core/database/secure/database_key_rotator.dart';
import 'package:isi_group_corporate_app/core/database/secure/dynamic_key_store.dart';
import 'package:isi_group_corporate_app/core/database/secure/key_derivation.dart';
import 'package:isi_group_corporate_app/core/database/hive/app_preferences.dart';
import 'package:isi_group_corporate_app/core/database/hive/hive_service.dart';
import 'package:isi_group_corporate_app/core/logging/app_logger.dart';
import 'package:isi_group_corporate_app/features/directory/directory_injection.dart';
import 'package:isi_group_corporate_app/core/network/connectivity_cubit.dart';
import 'package:isi_group_corporate_app/core/network/connectivity_service.dart';
import 'package:isi_group_corporate_app/core/network/network_info.dart';
import 'package:isi_group_corporate_app/core/security/security_injection.dart';
import 'package:isi_group_corporate_app/core/session/session_manager.dart';
import 'package:isi_group_corporate_app/features/app_coach/app_coach_injection.dart';
import 'package:isi_group_corporate_app/features/authentication/authentication_injection.dart';
import 'package:isi_group_corporate_app/features/hr_assistant/hr_assistant_injection.dart';
import 'package:isi_group_corporate_app/features/localization/presentation/bloc/language_cubit.dart';
import 'package:isi_group_corporate_app/features/profile/profile_injection.dart';
import 'package:isi_group_corporate_app/features/notification/notification_injection.dart';
import 'package:isi_group_corporate_app/features/settings/theme/theme_injection.dart';

/// Global service locator.
final GetIt sl = GetIt.instance;

/// Call once from `main()` before `runApp`.
Future<void> initDependencies() async {
  // ── External singletons ────────────────────────────────────────────
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // ── Encrypted database (Blueprint §3: composite-key SQLCipher) ──────
  sl.registerLazySingleton<DynamicKeyStore>(() => DynamicKeyStore(sl()));
  sl.registerLazySingleton<KeyDerivation>(() => const KeyDerivation());
  sl.registerLazySingleton<AppDatabaseKeyProvider>(
    () => AppDatabaseKeyProvider(
      deviceKeyStore: sl(),
      keyDerivation: sl(),
      salt: Env.dbSalt,
    ),
  );
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase.encrypted(sl()));
  sl.registerLazySingleton<DatabaseRekeyExecutor>(
    () => AppDatabaseRekeyExecutor(sl()),
  );
  sl.registerLazySingleton<DatabaseKeyRotator>(
    () => DatabaseKeyRotator(
      deviceKeyStore: sl(),
      keyDerivation: sl(),
      executor: sl(),
      salt: Env.dbSalt,
    ),
  );

  // ── Observability (SECURITY.md §10: structured, PII-free) ──────────
  sl.registerLazySingleton<AppLogger>(() => const ConsoleAppLogger());

  // ── Connectivity (ADR-005: real reachability, not interface-up) ─────
  // One instance, app-wide: the UI status pill and the sync drain trigger must
  // never disagree. No UI/bloc/repository/DAO may touch connectivity_plus.
  sl.registerLazySingleton<ReachabilityProbe>(
    () => HttpReachabilityProbe(dio: Dio(), logger: sl()),
  );
  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityServiceImpl(
      connectivity: sl(),
      probe: sl(),
      logger: sl(),
    ),
  );

  sl.registerFactory<ConnectivityCubit>(() => ConnectivityCubit(sl()));
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<SessionManager>(() => SessionManager());
  sl.registerLazySingleton<AppPreferences>(
    () => AppPreferencesImpl(HiveService.cacheBox),
  );
  sl.registerLazySingleton<LanguageCubit>(() => LanguageCubit(sl()));
  registerThemeFeature(sl);

  // ── Security infrastructure (SECURITY.md §2) ───────────────────────
  // Registered before the feature block: Authentication (biometric login) and
  // Profile (biometric onboarding) both resolve the same BiometricRepository,
  // so there is exactly one graph and one source of truth for whether
  // biometrics are enabled.
  registerSecurityInfrastructure(sl);

  // ── Features ───────────────────────────────────────────────────────
  registerAuthFeature(sl);
  registerProfileFeature(sl);
  registerNotificationFeature(sl);
  registerDirectoryFeature(sl);   // ← add
  registerHrAssistantFeature(sl);
  registerAppCoachFeature(sl);
}

