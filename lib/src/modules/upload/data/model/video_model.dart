import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_model.freezed.dart';
part 'video_model.g.dart';

@freezed
class Video with _$Video {
  const factory Video(
      {required String id,
      required String title,
      String? description,
      required String url,
      String? thumbnailUrl,
      required String status,
      required int userId,
      required DateTime createdAt,
      required DateTime updatedAt,
      String? cloudPath}) = _Video;

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
}

@freezed
class PresignedUrlResponse with _$PresignedUrlResponse {
  const factory PresignedUrlResponse({
    required String url,
  }) = _PresignedUrlResponse;

  factory PresignedUrlResponse.fromJson(Map<String, dynamic> json) =>
      _$PresignedUrlResponseFromJson(json);
}

@freezed
class VideoListResponse with _$VideoListResponse {
  const factory VideoListResponse({
    required List<Video> data,
    required PaginationInfo pagination,
  }) = _VideoListResponse;

  factory VideoListResponse.fromJson(Map<String, dynamic> json) =>
      _$VideoListResponseFromJson(json);
}

@freezed
class PaginationInfo with _$PaginationInfo {
  const factory PaginationInfo({
    required int totalItems,
    required int totalPages,
    required int pageSize,
    required int pageIndex,
  }) = _PaginationInfo;

  factory PaginationInfo.fromJson(Map<String, dynamic> json) =>
      _$PaginationInfoFromJson(json);
}
