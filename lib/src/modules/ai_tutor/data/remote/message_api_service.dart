import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/message_model.dart';

@injectable
class MessageApiService {
  final Dio _dio;

  MessageApiService(this._dio);

  /// Create message (user or bot)
  /// userId: null for bot messages, actual userId for user messages
  Future<MessageModel> createMessage(
    String conversationId,
    String content,
    int? userId,
  ) async {
    final response = await _dio.post(
      '/conversations/$conversationId/messages',
      data: {
        'content': content,
        'userId': userId,
      },
    );
    return MessageModel.fromJson(response.data);
  }

  /// Get messages for a conversation with pagination
  Future<PaginatedMessagesResponse> getMessages(
    String conversationId, {
    int pageIndex = 0,
    int pageSize = 50,
    String order = 'asc',
    String orderBy = 'createdAt',
  }) async {
    final response = await _dio.get(
      '/conversations/$conversationId/messages',
      queryParameters: {
        'pageIndex': pageIndex,
        'pageSize': pageSize,
        'order': order,
        'orderBy': orderBy,
      },
    );
    return PaginatedMessagesResponse.fromJson(response.data);
  }
}
