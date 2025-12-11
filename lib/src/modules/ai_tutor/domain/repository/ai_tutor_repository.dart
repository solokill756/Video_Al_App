import 'package:result_dart/result_dart.dart';

import 'package:dio/dio.dart';

import '../../../../core/data/remote/base/api_error.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
import '../../data/models/mastra_response_model.dart';
import '../../data/models/video_result_model.dart';

abstract class AITutorRepository {
  /// Conversations
  Future<Result<ConversationModel, ApiError>> createConversation(String name);

  Future<Result<PaginatedConversationsResponse, ApiError>> getConversations({
    int pageIndex = 1,
    int pageSize = 20,
    String order = 'desc',
    String orderBy = 'updatedAt',
  });

  Future<Result<ConversationModel, ApiError>> getConversation(String id);

  Future<Result<ConversationModel, ApiError>> updateConversation(
    String id,
    String name,
  );

  Future<Result<bool, ApiError>> deleteConversation(String id);

  /// Messages
  Future<Result<MessageModel, ApiError>> createMessage(
    String conversationId,
    String content,
    int? userId, // null for bot messages
  );

  Future<Result<PaginatedMessagesResponse, ApiError>> getMessages(
    String conversationId, {
    int pageIndex = 0,
    int pageSize = 50,
    String order = 'asc',
    String orderBy = 'createdAt',
  });

  /// AI Integration
  Future<Result<MastraResponseModel, ApiError>> sendMessageToAgent(
    String message,
    List<ConversationMessage> conversationHistory, {
    CancelToken? cancelToken,
  });

  List<VideoResultModel> parseVideoResults(MastraResponseModel response);

  /// Clean text for display by removing video URLs and formatting Markdown
  String cleanTextForDisplay(String text);
}
