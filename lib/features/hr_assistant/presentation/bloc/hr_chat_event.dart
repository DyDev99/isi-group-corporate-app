part of 'hr_chat_bloc.dart';

sealed class HrChatEvent {
  const HrChatEvent();
}

class HrChatStarted extends HrChatEvent {
  const HrChatStarted();
}

class HrChatCategoryChanged extends HrChatEvent {
  final HrCategory category;

  const HrChatCategoryChanged(this.category);
}

class HrChatQuestionSubmitted extends HrChatEvent {
  final String question;

  const HrChatQuestionSubmitted(this.question);
}

class HrChatAnswerRegenerated extends HrChatEvent {
  final String messageId;

  const HrChatAnswerRegenerated(this.messageId);
}

class HrChatGenerationStopped extends HrChatEvent {
  const HrChatGenerationStopped();
}

class HrChatMessageDismissed extends HrChatEvent {
  final String messageId;

  const HrChatMessageDismissed(this.messageId);
}

class HrChatMessageReacted extends HrChatEvent {
  final String messageId;
  final MessageReaction reaction;

  const HrChatMessageReacted(this.messageId, this.reaction);
}

class HrChatTextScaleChanged extends HrChatEvent {
  final double textScale;

  const HrChatTextScaleChanged(this.textScale);
}

class HrChatKnowledgeQueryChanged extends HrChatEvent {
  final String query;

  const HrChatKnowledgeQueryChanged(this.query);
}

class HrChatCleared extends HrChatEvent {
  const HrChatCleared();
}
