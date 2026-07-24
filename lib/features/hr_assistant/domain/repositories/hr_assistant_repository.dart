import '../entities/answer_event.dart';
import '../entities/hr_category.dart';
import '../entities/knowledge_doc.dart';
import '../entities/leave_balance.dart';

abstract class HrAssistantRepository {
  /// Streams the answer as it is composed. Throws an [HrFailure] subtype.
  Stream<AnswerEvent> ask({
    required String question,
    required HrCategory scope,
  });

  Future<String> greeting();

  Future<List<String>> suggestedQuestions(HrCategory category);

  Future<List<KnowledgeDoc>> searchDocs({
    String query,
    HrCategory category,
  });

  Future<LeaveBalance> leaveBalance();
}
