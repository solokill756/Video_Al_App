import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/conversation_model.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/video_result_model.dart';

part 'ai_tutor_state.freezed.dart';

@freezed
class AITutorState with _$AITutorState {
  const factory AITutorState({
    // Conversations
    @Default([]) List<ConversationModel> conversations,
    ConversationModel? activeConversation,
    @Default(false) bool isLoadingConversations,
    String? conversationsError,

    // Messages
    @Default([]) List<ChatMessage> messages,
    @Default(false) bool isLoadingMessages,
    String? messagesError,

    // AI
    @Default(false) bool isAILoading,
    String? aiError,

    // UI State
    @Default('') String inputText,
  }) = _AITutorState;
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String content,
    required bool isUser,
    required DateTime timestamp,
    @Default([]) List<VideoResultModel> videos,
    Map<String, dynamic>? rawResponse,
    @Default(false) bool isError,
  }) = _ChatMessage;

  factory ChatMessage.fromMessageModel(MessageModel message) {
    return ChatMessage(
      id: message.id,
      content: message.content,
      isUser: message.userId != null,
      timestamp: message.createdAt,
    );
  }
}
