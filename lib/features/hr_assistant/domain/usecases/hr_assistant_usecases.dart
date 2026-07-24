import '../entities/answer_event.dart';
import '../entities/hr_category.dart';
import '../entities/knowledge_doc.dart';
import '../entities/leave_balance.dart';
import '../repositories/hr_assistant_repository.dart';

/// One usecase per action (PLAYBOOK §2 naming table). Kept in one file only
/// because each is a two-line delegation; split them if any grows logic.

class AskHrAssistant {
  final HrAssistantRepository _repository;

  const AskHrAssistant(this._repository);

  Stream<AnswerEvent> call({
    required String question,
    required HrCategory scope,
  }) =>
      _repository.ask(question: question, scope: scope);
}

class GetGreeting {
  final HrAssistantRepository _repository;

  const GetGreeting(this._repository);

  Future<String> call() => _repository.greeting();
}

class GetSuggestedQuestions {
  final HrAssistantRepository _repository;

  const GetSuggestedQuestions(this._repository);

  Future<List<String>> call(HrCategory category) =>
      _repository.suggestedQuestions(category);
}

class SearchKnowledgeDocs {
  final HrAssistantRepository _repository;

  const SearchKnowledgeDocs(this._repository);

  Future<List<KnowledgeDoc>> call({
    String query = '',
    HrCategory category = HrCategory.all,
  }) =>
      _repository.searchDocs(query: query, category: category);
}

class GetLeaveBalance {
  final HrAssistantRepository _repository;

  const GetLeaveBalance(this._repository);

  Future<LeaveBalance> call() => _repository.leaveBalance();
}
