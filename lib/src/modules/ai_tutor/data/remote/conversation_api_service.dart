import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/conversation_model.dart';

@injectable
class ConversationApiService {
  final Dio _dio;

  ConversationApiService(this._dio);

  /// Create new conversation
  Future<ConversationModel> createConversation(String name) async {
    final response = await _dio.post(
      '/conversations',
      data: {'name': name},
    );
    return ConversationModel.fromJson(response.data);
  }

  /// Get all conversations with pagination
  Future<PaginatedConversationsResponse> getConversations({
    int pageIndex = 1,
    int pageSize = 20,
    String order = 'desc',
    String orderBy = 'updatedAt',
  }) async {
    final response = await _dio.get(
      '/conversations',
      queryParameters: {
        'pageIndex': pageIndex,
        'pageSize': pageSize,
        'order': order,
        'orderBy': orderBy,
      },
    );
    return PaginatedConversationsResponse.fromJson(response.data);
  }

  /// Get single conversation
  Future<ConversationModel> getConversation(String id) async {
    final response = await _dio.get('/conversations/$id');
    return ConversationModel.fromJson(response.data);
  }

  /// Update conversation name
  Future<ConversationModel> updateConversation(String id, String name) async {
    final response = await _dio.patch(
      '/conversations/$id',
      data: {'name': name},
    );
    return ConversationModel.fromJson(response.data);
  }

  /// Delete conversation
  Future<void> deleteConversation(String id) async {
    await _dio.delete('/conversations/$id');
  }
}
