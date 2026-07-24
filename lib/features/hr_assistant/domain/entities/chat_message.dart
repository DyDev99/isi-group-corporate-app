import 'knowledge_doc.dart';
import 'leave_balance.dart';

enum MessageAuthor { user, assistant }

enum MessageStatus { sending, streaming, complete, failed }

enum MessageReaction { none, helpful, notHelpful }

/// One turn in the conversation. Immutable — every mutation returns a new
/// instance (AI_ENGINEERING_PLAYBOOK §1).
class ChatMessage {
  final String id;
  final MessageAuthor author;
  final String text;
  final DateTime createdAt;
  final MessageStatus status;
  final MessageReaction reaction;

  /// Documents the answer was grounded in — rendered as the swipeable
  /// evidence carousel under the bubble.
  final List<KnowledgeDoc> sources;

  /// Rich payload attached to the answer, when the intent resolves to one.
  final LeaveBalance? leaveBalance;

  final List<String> followUps;

  /// 0..1 retrieval confidence, shown as the meter on the answer.
  final double? confidence;

  const ChatMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
    this.status = MessageStatus.complete,
    this.reaction = MessageReaction.none,
    this.sources = const [],
    this.leaveBalance,
    this.followUps = const [],
    this.confidence,
  });

  bool get isUser => author == MessageAuthor.user;

  bool get isStreaming => status == MessageStatus.streaming;

  ChatMessage copyWith({
    String? text,
    MessageStatus? status,
    MessageReaction? reaction,
    List<KnowledgeDoc>? sources,
    LeaveBalance? leaveBalance,
    List<String>? followUps,
    double? confidence,
  }) =>
      ChatMessage(
        id: id,
        author: author,
        text: text ?? this.text,
        createdAt: createdAt,
        status: status ?? this.status,
        reaction: reaction ?? this.reaction,
        sources: sources ?? this.sources,
        leaveBalance: leaveBalance ?? this.leaveBalance,
        followUps: followUps ?? this.followUps,
        confidence: confidence ?? this.confidence,
      );
}
