import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/datasources/hr_assistant_mock_datasource.dart';
import 'data/repositories/hr_assistant_repository_impl.dart';
import 'domain/repositories/hr_assistant_repository.dart';
import 'domain/usecases/hr_assistant_usecases.dart';
import 'presentation/bloc/hr_chat_bloc.dart';
import 'presentation/pages/hr_ai_assistant_screen.dart';

/// Drop-in entry point:
///
/// ```dart
/// Navigator.of(context).push(
///   MaterialPageRoute(builder: (_) => const HrAssistantScope()),
/// );
/// ```
///
/// Builds the dependency graph by hand so the screen runs in a demo app with
/// no service locator. In the main app, register the feature with
/// `registerHrAssistantFeature(sl)` and provide `sl<HrChatBloc>()` instead.
class HrAssistantScope extends StatelessWidget {
  const HrAssistantScope({super.key});

  @override
  Widget build(BuildContext context) {
    final HrAssistantRepository repository =
        HrAssistantRepositoryImpl(HrAssistantMockDatasource());

    return BlocProvider<HrChatBloc>(
      create: (_) => HrChatBloc(
        ask: AskHrAssistant(repository),
        getGreeting: GetGreeting(repository),
        getSuggestions: GetSuggestedQuestions(repository),
        searchDocs: SearchKnowledgeDocs(repository),
      )..add(const HrChatStarted()),
      child: const HrAiAssistantScreen(),
    );
  }
}
