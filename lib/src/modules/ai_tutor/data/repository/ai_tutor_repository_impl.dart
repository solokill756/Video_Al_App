import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:result_dart/result_dart.dart';

import '../../../../core/data/remote/base/api_error.dart';
import '../../../../core/data/remote/services/api_service.dart';
import '../../domain/repository/ai_tutor_repository.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/mastra_response_model.dart';
import '../models/video_result_model.dart';
import '../remote/conversation_api_service.dart';
import '../remote/message_api_service.dart';
import '../remote/mastra_api_service.dart';

@Injectable(as: AITutorRepository)
class AITutorRepositoryImpl implements AITutorRepository {
  final ConversationApiService _conversationApiService;
  final MessageApiService _messageApiService;
  final MastraApiService _mastraApiService;

  AITutorRepositoryImpl(
    this._conversationApiService,
    this._messageApiService,
    this._mastraApiService,
  );

  @override
  Future<Result<ConversationModel, ApiError>> createConversation(
    String name,
  ) async {
    return await _conversationApiService
        .createConversation(name)
        .tryGet((response) => response);
  }

  @override
  Future<Result<PaginatedConversationsResponse, ApiError>> getConversations({
    int pageIndex = 1,
    int pageSize = 20,
    String order = 'desc',
    String orderBy = 'updatedAt',
  }) async {
    return await _conversationApiService
        .getConversations(
          pageIndex: pageIndex,
          pageSize: pageSize,
          order: order,
          orderBy: orderBy,
        )
        .tryGet((response) => response);
  }

  @override
  Future<Result<ConversationModel, ApiError>> getConversation(String id) async {
    return await _conversationApiService
        .getConversation(id)
        .tryGet((response) => response);
  }

  @override
  Future<Result<ConversationModel, ApiError>> updateConversation(
    String id,
    String name,
  ) async {
    return await _conversationApiService
        .updateConversation(id, name)
        .tryGet((response) => response);
  }

  @override
  Future<Result<bool, ApiError>> deleteConversation(String id) async {
    try {
      await _conversationApiService.deleteConversation(id);
      return const Success(true);
    } on ApiError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ApiError.unexpected());
    }
  }

  @override
  Future<Result<MessageModel, ApiError>> createMessage(
    String conversationId,
    String content,
    int? userId,
  ) async {
    return await _messageApiService
        .createMessage(conversationId, content, userId)
        .tryGet((response) => response);
  }

  @override
  Future<Result<PaginatedMessagesResponse, ApiError>> getMessages(
    String conversationId, {
    int pageIndex = 1,
    int pageSize = 50,
    String order = 'asc',
    String orderBy = 'createdAt',
  }) async {
    return await _messageApiService
        .getMessages(
          conversationId,
          pageIndex: pageIndex,
          pageSize: pageSize,
          order: order,
          orderBy: orderBy,
        )
        .tryGet((response) => response);
  }

  @override
  Future<Result<MastraResponseModel, ApiError>> sendMessageToAgent(
    String message,
    List<ConversationMessage> conversationHistory, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _mastraApiService.sendMessageToAgent(
        message,
        conversationHistory,
        cancelToken: cancelToken,
      );
      return response.toSuccess();
    } catch (e) {
      if (e.toString().contains('cancelled')) {
        return ApiError.network(
          code: -1,
          message: 'Request was cancelled',
        ).toFailure();
      }
      return ApiError.network(
        code: -1,
        message: e.toString(),
      ).toFailure();
    }
  }

  @override
  List<VideoResultModel> parseVideoResults(MastraResponseModel response) {
    return _mastraApiService.parseVideoResults(response);
  }

  @override
  String cleanTextForDisplay(String text) {
    return _mastraApiService.cleanTextForDisplay(text);
  }
}
