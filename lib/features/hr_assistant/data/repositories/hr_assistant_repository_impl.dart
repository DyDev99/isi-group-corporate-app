import '../../domain/entities/answer_event.dart';
import '../../domain/entities/hr_category.dart';
import '../../domain/entities/knowledge_doc.dart';
import '../../domain/entities/leave_balance.dart';
import '../../domain/failures/hr_failure.dart';
import '../../domain/repositories/hr_assistant_repository.dart';
import '../datasources/hr_assistant_mock_datasource.dart';

class HrAssistantRepositoryImpl implements HrAssistantRepository {
  final HrAssistantMockDatasource _datasource;

  const HrAssistantRepositoryImpl(this._datasource);

  @override
  Stream<AnswerEvent> ask({
    required String question,
    required HrCategory scope,
  }) async* {
    try {
      yield* _datasource.ask(question: question, scope: scope);
    } on Object catch (_) {
      // Typed failure crosses into presentation, never the raw exception.
      throw const HrRetrievalFailure();
    }
  }

  @override
  Future<String> greeting() async => _datasource.greeting();

  @override
  Future<List<String>> suggestedQuestions(HrCategory category) async =>
      _datasource.suggestedQuestions(category);

  @override
  Future<List<KnowledgeDoc>> searchDocs({
    String query = '',
    HrCategory category = HrCategory.all,
  }) async =>
      _datasource.searchDocs(query: query, category: category);

  @override
  Future<LeaveBalance> leaveBalance() async => _datasource.leaveBalance();
}
