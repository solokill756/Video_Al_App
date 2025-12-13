import 'package:freezed_annotation/freezed_annotation.dart';
import 'conversation_model.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id,
    required String content,
    int? userId, // null = bot message
    required String conversationId,
    required DateTime createdAt,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);
}

@freezed
class PaginatedMessagesResponse with _$PaginatedMessagesResponse {
  const factory PaginatedMessagesResponse({
    required List<MessageModel> data,
    required PaginationMeta pagination,
  }) = _PaginatedMessagesResponse;

  factory PaginatedMessagesResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedMessagesResponseFromJson(json);
}
