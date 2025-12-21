import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../Settings/domain/repository/settings_repository.dart';
import '../../../data/models/mastra_response_model.dart';
import '../../../domain/repository/ai_tutor_repository.dart';
import 'ai_tutor_state.dart';

@Singleton()
class AITutorCubit extends Cubit<AITutorState> {
  final AITutorRepository _repository;
  final SettingsRepository _settingsRepository;
  CancelToken? _currentAICancelToken;

  AITutorCubit(
    this._repository,
    this._settingsRepository,
  ) : super(const AITutorState());

  /// Load conversations
  Future<void> loadConversations() async {
    emit(
        state.copyWith(isLoadingConversations: true, conversationsError: null));

    final result = await _repository.getConversations();

    result.fold(
      (response) {
        emit(state.copyWith(
          conversations: response.data,
          isLoadingConversations: false,
          conversationsError: null,
        ));

        // Auto-select first conversation if none selected
        if (state.activeConversation == null && response.data.isNotEmpty) {
          selectConversation(response.data.first.id);
        }
      },
      (error) {
        emit(state.copyWith(
          isLoadingConversations: false,
          conversationsError: error.message,
        ));
      },
    );
  }

  /// Create new conversation
  Future<void> createConversation() async {
    final conversationCount = state.conversations.length;
    final name = 'Chat ${conversationCount + 1}';

    final result = await _repository.createConversation(name);

    result.fold(
      (conversation) {
        emit(state.copyWith(
          conversations: [conversation, ...state.conversations],
          activeConversation: conversation,
          messages: [],
        ));
      },
      (error) {
        emit(state.copyWith(conversationsError: error.message));
      },
    );
  }

  /// Select conversation
  Future<void> selectConversation(String conversationId) async {
    // Cancel any ongoing AI request
    _cancelAICall();

    // Find conversation
    final conversation = state.conversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => throw Exception('Conversation not found'),
    );

    emit(state.copyWith(
      activeConversation: conversation,
      messages: [],
      isLoadingMessages: true,
      messagesError: null,
    ));

    // Load messages
    await loadMessages(conversationId);
  }

  /// Load messages for a conversation
  Future<void> loadMessages(String conversationId) async {
    emit(state.copyWith(isLoadingMessages: true, messagesError: null));

    final result = await _repository.getMessages(conversationId);

    result.fold(
      (response) {
        final chatMessages = response.data.map((msg) {
          final isUser = msg.userId != null;
          final rawContent = msg.content;

          // For bot messages, parse videos and clean text
          if (!isUser) {
            final videos = _repository.parseVideoResults(
              MastraResponseModel(
                text: rawContent,
                toolOutput: null,
              ),
            );

            // Clean text for display
            final cleanedContent = _repository.cleanTextForDisplay(rawContent);

            return ChatMessage(
              id: msg.id,
              content: cleanedContent,
              isUser: false,
              timestamp: msg.createdAt,
              videos: videos,
            );
          } else {
            // User messages don't need formatting
            return ChatMessage.fromMessageModel(msg);
          }
        }).toList();

        emit(state.copyWith(
          messages: chatMessages,
          isLoadingMessages: false,
          messagesError: null,
        ));
      },
      (error) {
        emit(state.copyWith(
          isLoadingMessages: false,
          messagesError: error.message,
        ));
      },
    );
  }

  /// Update conversation name
  Future<void> updateConversationName(
      String conversationId, String name) async {
    final result = await _repository.updateConversation(conversationId, name);

    result.fold(
      (updated) {
        final updatedConversations = state.conversations.map((c) {
          return c.id == conversationId ? updated : c;
        }).toList();

        emit(state.copyWith(
          conversations: updatedConversations,
          activeConversation: state.activeConversation?.id == conversationId
              ? updated
              : state.activeConversation,
        ));
      },
      (error) {
        emit(state.copyWith(conversationsError: error.message));
      },
    );
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    // Optimistic update
    final conversationsBefore = state.conversations;
    conversationsBefore.firstWhere(
      (c) => c.id == conversationId,
    );

    emit(state.copyWith(
      conversations:
          conversationsBefore.where((c) => c.id != conversationId).toList(),
    ));

    // If deleted conversation was active, switch to another or clear
    if (state.activeConversation?.id == conversationId) {
      final remaining = state.conversations;
      if (remaining.isNotEmpty) {
        selectConversation(remaining.first.id);
      } else {
        emit(state.copyWith(
          activeConversation: null,
          messages: [],
        ));
      }
    }

    // Call API
    final result = await _repository.deleteConversation(conversationId);

    result.fold(
      (_) {
        // Success - already updated
      },
      (error) {
        // Rollback on error
        emit(state.copyWith(
          conversations: conversationsBefore,
          conversationsError: error.message,
        ));
      },
    );
  }

  /// Send message
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    if (state.activeConversation == null) {
      // Create conversation first
      await createConversation();
      if (state.activeConversation == null) return;
    }

    final conversationId = state.activeConversation!.id;
    final userId = await _getUserId();

    // Add user message to UI immediately
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );

    emit(state.copyWith(
      messages: [...state.messages, userMessage],
      inputText: '',
    ));

    // Save user message to backend
    final userMsgResult = await _repository.createMessage(
      conversationId,
      content,
      userId,
    );

    userMsgResult.fold(
      (savedMessage) {
        // Update message with saved ID
        final updatedMessages = state.messages.map((msg) {
          return msg.id == userMessage.id
              ? ChatMessage(
                  id: savedMessage.id,
                  content: msg.content,
                  isUser: msg.isUser,
                  timestamp: msg.timestamp,
                )
              : msg;
        }).toList();

        emit(state.copyWith(messages: updatedMessages));
      },
      (error) {
        // Mark message as error
        final updatedMessages = state.messages.map((msg) {
          return msg.id == userMessage.id ? msg.copyWith(isError: true) : msg;
        }).toList();

        emit(state.copyWith(
          messages: updatedMessages,
          messagesError: error.message,
        ));
        return;
      },
    );

    // Prepare conversation history for AI
    final history = state.messages.map((msg) {
      return ConversationMessage(
        role: msg.isUser ? 'user' : 'assistant',
        content: msg.content,
      );
    }).toList();

    // Call AI
    await _callAI(content, history, conversationId);
  }

  /// Call AI agent
  Future<void> _callAI(
    String message,
    List<ConversationMessage> history,
    String conversationId,
  ) async {
    emit(state.copyWith(isAILoading: true, aiError: null));

    // Create cancel token
    _currentAICancelToken = CancelToken();

    final result = await _repository.sendMessageToAgent(
      message,
      history,
      cancelToken: _currentAICancelToken,
    );

    _currentAICancelToken = null;

    result.fold(
      (aiResponse) async {
        final rawText =
            aiResponse.text ?? "Sorry, I can't answer this question.";
        final videos = _repository.parseVideoResults(aiResponse);

        // Clean text for display: remove video URLs and format Markdown
        final cleanedText = _repository.cleanTextForDisplay(rawText);

        // Save bot message to backend (save original text with URLs for reference)
        final botMsgResult = await _repository.createMessage(
          conversationId,
          rawText, // Save original text with URLs
          null, // null = bot message
        );

        botMsgResult.fold(
          (savedMessage) {
            final botMessage = ChatMessage(
              id: savedMessage.id,
              content: cleanedText, // Display cleaned text
              isUser: false,
              timestamp: savedMessage.createdAt,
              videos: videos,
              rawResponse: {'rawText': rawText}, // Store raw text for parsing
            );

            emit(state.copyWith(
              messages: [...state.messages, botMessage],
              isAILoading: false,
              aiError: null,
            ));
          },
          (error) {
            // Still show message even if save fails
            final botMessage = ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              content: cleanedText, // Use cleaned text
              isUser: false,
              timestamp: DateTime.now(),
              videos: videos,
              isError: true,
            );

            emit(state.copyWith(
              messages: [...state.messages, botMessage],
              isAILoading: false,
              aiError: error.message,
            ));
          },
        );
      },
      (error) {
        emit(state.copyWith(
          isAILoading: false,
          aiError: error.message,
        ));
      },
    );
  }

  /// Cancel ongoing AI request
  void _cancelAICall() {
    _currentAICancelToken?.cancel();
    _currentAICancelToken = null;
    emit(state.copyWith(isAILoading: false));
  }

  /// Get user ID from settings
  Future<int?> _getUserId() async {
    final result = await _settingsRepository.getCurrentUser();
    return result.fold(
      (user) => user.id,
      (_) => null,
    );
  }

  /// Update input text
  void updateInputText(String text) {
    emit(state.copyWith(inputText: text));
  }

  @override
  Future<void> close() {
    _cancelAICall();
    return super.close();
  }
}
