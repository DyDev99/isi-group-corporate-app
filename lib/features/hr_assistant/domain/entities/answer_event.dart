import 'knowledge_doc.dart';
import 'leave_balance.dart';

/// What the assistant emits while composing an answer. Sealed so the bloc's
/// switch is exhaustive and a new event type becomes a compile error, not a
/// silently ignored branch.
sealed class AnswerEvent {
  const AnswerEvent();
}

/// The assistant is retrieving before it starts writing.
class AnswerRetrieving extends AnswerEvent {
  const AnswerRetrieving();
}

/// A slice of answer text to append to the current bubble.
class AnswerTextChunk extends AnswerEvent {
  final String text;

  const AnswerTextChunk(this.text);
}

/// The answer is finished; carries everything rendered below the text.
class AnswerCompleted extends AnswerEvent {
  final List<KnowledgeDoc> sources;
  final LeaveBalance? leaveBalance;
  final List<String> followUps;
  final double confidence;

  const AnswerCompleted({
    this.sources = const [],
    this.leaveBalance,
    this.followUps = const [],
    this.confidence = 0.9,
  });
}
