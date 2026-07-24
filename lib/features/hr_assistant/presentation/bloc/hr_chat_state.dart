part of 'hr_chat_bloc.dart';

enum HrChatStatus { initial, loading, ready, failure }

class HrChatState {
  final HrChatStatus status;
  final List<ChatMessage> messages;
  final HrCategory category;
  final List<String> suggestions;

  /// Filtered corpus backing the Knowledge Center sheet.
  final List<KnowledgeDoc> docs;
  final String knowledgeQuery;

  /// 0.9 – 1.3, driven by the A−/A+ control in the app bar.
  final double textScale;
  final bool isAnswering;
  final String? failureMessage;

  const HrChatState({
    this.status = HrChatStatus.initial,
    this.messages = const [],
    this.category = HrCategory.all,
    this.suggestions = const [],
    this.docs = const [],
    this.knowledgeQuery = '',
    this.textScale = 1.0,
    this.isAnswering = false,
    this.failureMessage,
  });

  bool get isGreetingOnly => messages.length <= 1;

  HrChatState copyWith({
    HrChatStatus? status,
    List<ChatMessage>? messages,
    HrCategory? category,
    List<String>? suggestions,
    List<KnowledgeDoc>? docs,
    String? knowledgeQuery,
    double? textScale,
    bool? isAnswering,
    String? failureMessage,
    bool clearFailure = false,
  }) =>
      HrChatState(
        status: status ?? this.status,
        messages: messages ?? this.messages,
        category: category ?? this.category,
        suggestions: suggestions ?? this.suggestions,
        docs: docs ?? this.docs,
        knowledgeQuery: knowledgeQuery ?? this.knowledgeQuery,
        textScale: textScale ?? this.textScale,
        isAnswering: isAnswering ?? this.isAnswering,
        failureMessage: clearFailure ? null : (failureMessage ?? this.failureMessage),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HrChatState &&
          other.status == status &&
          other.messages == messages &&
          other.category == category &&
          other.suggestions == suggestions &&
          other.docs == docs &&
          other.knowledgeQuery == knowledgeQuery &&
          other.textScale == textScale &&
          other.isAnswering == isAnswering &&
          other.failureMessage == failureMessage;

  @override
  int get hashCode => Object.hash(
        status,
        messages,
        category,
        suggestions,
        docs,
        knowledgeQuery,
        textScale,
        isAnswering,
        failureMessage,
      );
}
