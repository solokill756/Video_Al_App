import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_model.freezed.dart';
part 'conversation_model.g.dart';

@freezed
class ConversationModel with _$ConversationModel {
  const factory ConversationModel({
    required String id,
    required String name,
    required int userId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ConversationModel;

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);
}

@freezed
class PaginatedConversationsResponse with _$PaginatedConversationsResponse {
  const factory PaginatedConversationsResponse({
    required List<ConversationModel> data,
    required PaginationMeta pagination,
  }) = _PaginatedConversationsResponse;

  factory PaginatedConversationsResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedConversationsResponseFromJson(json);
}

@freezed
class PaginationMeta with _$PaginationMeta {
  const factory PaginationMeta({
    required int totalItems,
    required int pageIndex,
    required int pageSize,
    required int totalPages,
  }) = _PaginationMeta;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);
}
