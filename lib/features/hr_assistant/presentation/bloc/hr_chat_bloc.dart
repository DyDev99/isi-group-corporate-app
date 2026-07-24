import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/answer_event.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/hr_category.dart';
import '../../domain/entities/knowledge_doc.dart';
import '../../domain/failures/hr_failure.dart';
import '../../domain/usecases/hr_assistant_usecases.dart';

part 'hr_chat_event.dart';
part 'hr_chat_state.dart';

/// Owns every piece of conversation logic. Widgets render this state and
/// nothing else (PLAYBOOK §1: no business logic in widgets).
class HrChatBloc extends Bloc<HrChatEvent, HrChatState> {
  final AskHrAssistant _ask;
  final GetGreeting _getGreeting;
  final GetSuggestedQuestions _getSuggestions;
  final SearchKnowledgeDocs _searchDocs;

  bool _stopRequested = false;
  int _sequence = 0;

  HrChatBloc({
    required AskHrAssistant ask,
    required GetGreeting getGreeting,
    required GetSuggestedQuestions getSuggestions,
    required SearchKnowledgeDocs searchDocs,
  })  : _ask = ask,
        _getGreeting = getGreeting,
        _getSuggestions = getSuggestions,
        _searchDocs = searchDocs,
        super(const HrChatState()) {
    on<HrChatStarted>(_onStarted);
    on<HrChatCategoryChanged>(_onCategoryChanged);
    on<HrChatQuestionSubmitted>(_onQuestionSubmitted);
    on<HrChatAnswerRegenerated>(_onRegenerated);
    on<HrChatGenerationStopped>(_onGenerationStopped);
    on<HrChatMessageDismissed>(_onMessageDismissed);
    on<HrChatMessageReacted>(_onMessageReacted);
    on<HrChatTextScaleChanged>(_onTextScaleChanged);
    on<HrChatKnowledgeQueryChanged>(_onKnowledgeQueryChanged);
    on<HrChatCleared>(_onCleared);
  }

  String _nextId(String prefix) => '${prefix}_${_sequence++}';

  Future<void> _onStarted(HrChatStarted event, Emitter<HrChatState> emit) async {
    emit(state.copyWith(status: HrChatStatus.loading));
    final greeting = await _getGreeting();
    final suggestions = await _getSuggestions(state.category);
    final docs = await _searchDocs(category: state.category);

    emit(state.copyWith(
      status: HrChatStatus.ready,
      suggestions: suggestions,
      docs: docs,
      messages: [
        ChatMessage(
          id: _nextId('greeting'),
          author: MessageAuthor.assistant,
          text: greeting,
          createdAt: DateTime.now(),
        ),
      ],
    ));
  }

  Future<void> _onCategoryChanged(
    HrChatCategoryChanged event,
    Emitter<HrChatState> emit,
  ) async {
    if (event.category == state.category) return;
    final suggestions = await _getSuggestions(event.category);
    final docs = await _searchDocs(
      query: state.knowledgeQuery,
      category: event.category,
    );
    emit(state.copyWith(
      category: event.category,
      suggestions: suggestions,
      docs: docs,
    ));
  }

  Future<void> _onQuestionSubmitted(
    HrChatQuestionSubmitted event,
    Emitter<HrChatState> emit,
  ) async {
    final question = event.question.trim();
    if (question.isEmpty || state.isAnswering) return;

    final userMessage = ChatMessage(
      id: _nextId('user'),
      author: MessageAuthor.user,
      text: question,
      createdAt: DateTime.now(),
    );

    emit(state.copyWith(
      messages: [...state.messages, userMessage],
      clearFailure: true,
    ));

    await _streamAnswer(question, emit);
  }

  Future<void> _onRegenerated(
    HrChatAnswerRegenerated event,
    Emitter<HrChatState> emit,
  ) async {
    if (state.isAnswering) return;

    final index = state.messages.indexWhere((m) => m.id == event.messageId);
    if (index <= 0) return;

    final question = state.messages
        .sublist(0, index)
        .lastWhere(
          (m) => m.isUser,
          orElse: () => state.messages[index],
        )
        .text;

    final trimmed = [...state.messages]..removeAt(index);
    emit(state.copyWith(messages: trimmed, clearFailure: true));

    await _streamAnswer(question, emit);
  }

  Future<void> _streamAnswer(String question, Emitter<HrChatState> emit) async {
    _stopRequested = false;

    final answerId = _nextId('answer');
    final placeholder = ChatMessage(
      id: answerId,
      author: MessageAuthor.assistant,
      text: '',
      createdAt: DateTime.now(),
      status: MessageStatus.streaming,
    );

    emit(state.copyWith(
      messages: [...state.messages, placeholder],
      isAnswering: true,
    ));

    try {
      await for (final answerEvent
          in _ask(question: question, scope: state.category)) {
        if (_stopRequested || emit.isDone) break;

        switch (answerEvent) {
          case AnswerRetrieving():
            break;
          case AnswerTextChunk(:final text):
            emit(state.copyWith(
              messages: _patch(answerId, (m) => m.copyWith(text: text)),
            ));
          case AnswerCompleted(
              :final sources,
              :final leaveBalance,
              :final followUps,
              :final confidence
            ):
            emit(state.copyWith(
              isAnswering: false,
              messages: _patch(
                answerId,
                (m) => m.copyWith(
                  status: MessageStatus.complete,
                  sources: sources,
                  leaveBalance: leaveBalance,
                  followUps: followUps,
                  confidence: confidence,
                ),
              ),
            ));
        }
      }
    } on HrFailure catch (failure) {
      emit(state.copyWith(
        isAnswering: false,
        failureMessage: failure.message,
        messages: _patch(
          answerId,
          (m) => m.copyWith(
            status: MessageStatus.failed,
            text: failure.message,
          ),
        ),
      ));
      return;
    }

    if (state.isAnswering && !emit.isDone) {
      emit(state.copyWith(
        isAnswering: false,
        messages: _patch(
          answerId,
          (m) => m.copyWith(status: MessageStatus.complete),
        ),
      ));
    }
  }

  void _onGenerationStopped(
    HrChatGenerationStopped event,
    Emitter<HrChatState> emit,
  ) {
    _stopRequested = true;
  }

  void _onMessageDismissed(
    HrChatMessageDismissed event,
    Emitter<HrChatState> emit,
  ) {
    emit(state.copyWith(
      messages: state.messages.where((m) => m.id != event.messageId).toList(),
    ));
  }

  void _onMessageReacted(
    HrChatMessageReacted event,
    Emitter<HrChatState> emit,
  ) {
    emit(state.copyWith(
      messages: _patch(
        event.messageId,
        (m) => m.copyWith(
          reaction: m.reaction == event.reaction
              ? MessageReaction.none
              : event.reaction,
        ),
      ),
    ));
  }

  void _onTextScaleChanged(
    HrChatTextScaleChanged event,
    Emitter<HrChatState> emit,
  ) {
    emit(state.copyWith(textScale: event.textScale.clamp(0.9, 1.3).toDouble()));
  }

  Future<void> _onKnowledgeQueryChanged(
    HrChatKnowledgeQueryChanged event,
    Emitter<HrChatState> emit,
  ) async {
    final docs = await _searchDocs(
      query: event.query,
      category: state.category,
    );
    emit(state.copyWith(knowledgeQuery: event.query, docs: docs));
  }

  Future<void> _onCleared(HrChatCleared event, Emitter<HrChatState> emit) async {
    _stopRequested = true;
    final greeting = await _getGreeting();
    emit(state.copyWith(
      isAnswering: false,
      clearFailure: true,
      messages: [
        ChatMessage(
          id: _nextId('greeting'),
          author: MessageAuthor.assistant,
          text: greeting,
          createdAt: DateTime.now(),
        ),
      ],
    ));
  }

  List<ChatMessage> _patch(
    String id,
    ChatMessage Function(ChatMessage) update,
  ) =>
      [
        for (final message in state.messages)
          if (message.id == id) update(message) else message,
      ];
}
