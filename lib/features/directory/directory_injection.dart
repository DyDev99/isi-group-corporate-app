import 'package:get_it/get_it.dart';

import 'data/datasources/directory_mock_datasource.dart';
import 'data/repositories/directory_repository_impl.dart';
import 'domain/repositories/directory_repository.dart';
import 'domain/usecases/directory_usecases.dart';
import 'presentation/bloc/directory_bloc.dart';

/// One `register<Feature>Feature(GetIt sl)` at the feature root, called from
/// the single app-level entrypoint in `core/di/` — ENGINEERING_STANDARD §5.
///
/// If the demo app has no `get_it`, delete this file and use
/// `directory_scope.dart`; nothing else references it.
void registerDirectoryFeature(GetIt sl) {
  sl
    ..registerLazySingleton<DirectoryMockDatasource>(
      DirectoryMockDatasource.new,
    )
    ..registerLazySingleton<DirectoryRepository>(
      () => DirectoryRepositoryImpl(sl<DirectoryMockDatasource>()),
    )
    ..registerLazySingleton(() => GetOrgTree(sl<DirectoryRepository>()))
    ..registerLazySingleton(() => GetCompanies(sl<DirectoryRepository>()))
    ..registerLazySingleton(() => GetDepartments(sl<DirectoryRepository>()))
    ..registerFactory(
      () => DirectoryBloc(
        getOrgTree: sl<GetOrgTree>(),
        getCompanies: sl<GetCompanies>(),
        getDepartments: sl<GetDepartments>(),
      ),
    );
}
