import 'package:get_it/get_it.dart';

import 'data/datasources/hr_assistant_mock_datasource.dart';
import 'data/repositories/hr_assistant_repository_impl.dart';
import 'domain/repositories/hr_assistant_repository.dart';
import 'domain/usecases/hr_assistant_usecases.dart';
import 'presentation/bloc/hr_chat_bloc.dart';

/// One `register<Feature>Feature(GetIt sl)` at the feature root, called from
/// the app-level entrypoint in `core/di/` — ENGINEERING_STANDARD §5.
///
/// If this demo app does not use get_it, delete this file and use
/// `hr_assistant_scope.dart` instead; nothing else references it.
void registerHrAssistantFeature(GetIt sl) {
  sl
    ..registerLazySingleton<HrAssistantMockDatasource>(
      HrAssistantMockDatasource.new,
    )
    ..registerLazySingleton<HrAssistantRepository>(
      () => HrAssistantRepositoryImpl(sl<HrAssistantMockDatasource>()),
    )
    ..registerLazySingleton(() => AskHrAssistant(sl<HrAssistantRepository>()))
    ..registerLazySingleton(() => GetGreeting(sl<HrAssistantRepository>()))
    ..registerLazySingleton(
      () => GetSuggestedQuestions(sl<HrAssistantRepository>()),
    )
    ..registerLazySingleton(
      () => SearchKnowledgeDocs(sl<HrAssistantRepository>()),
    )
    ..registerLazySingleton(() => GetLeaveBalance(sl<HrAssistantRepository>()))
    ..registerFactory(
      () => HrChatBloc(
        ask: sl<AskHrAssistant>(),
        getGreeting: sl<GetGreeting>(),
        getSuggestions: sl<GetSuggestedQuestions>(),
        searchDocs: sl<SearchKnowledgeDocs>(),
      ),
    );
}
