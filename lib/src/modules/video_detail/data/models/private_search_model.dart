import 'package:freezed_annotation/freezed_annotation.dart';

part 'private_search_model.freezed.dart';
part 'private_search_model.g.dart';

@freezed
class LoadDataResponse with _$LoadDataResponse {
  const factory LoadDataResponse({
    @JsonKey(name: 'session_id') required String sessionId,
    required String message,
    @JsonKey(name: 'total_videos') required int totalVideos,
    @JsonKey(name: 'total_vectors') required int totalVectors,
  }) = _LoadDataResponse;

  factory LoadDataResponse.fromJson(Map<String, dynamic> json) =>
      _$LoadDataResponseFromJson(json);
}

@freezed
class PrivateSearchResult with _$PrivateSearchResult {
  const factory PrivateSearchResult({
    @JsonKey(name: 'image_path') required String imagePath,
    required double score,
    @JsonKey(name: 'pts_time') required double ptsTime,
    @JsonKey(name: 'frame_idx') required int frameIdx,
    @JsonKey(name: 'video_id') required String videoId,
  }) = _PrivateSearchResult;

  factory PrivateSearchResult.fromJson(Map<String, dynamic> json) =>
      _$PrivateSearchResultFromJson(json);
}

@freezed
class PrivateSearchResponse with _$PrivateSearchResponse {
  const factory PrivateSearchResponse({
    @JsonKey(name: 'session_id') required String sessionId,
    required List<PrivateSearchResult> results,
    @JsonKey(name: 'took_ms') required int tookMs,
    @JsonKey(name: 'total_indexed') required int totalIndexed,
  }) = _PrivateSearchResponse;

  factory PrivateSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$PrivateSearchResponseFromJson(json);
}

@freezed
class TextSearchRequest with _$TextSearchRequest {
  const factory TextSearchRequest({
    @JsonKey(name: 'session_id') required String sessionId,
    required String query,
    @Default(20) int topK,
  }) = _TextSearchRequest;

  factory TextSearchRequest.fromJson(Map<String, dynamic> json) =>
      _$TextSearchRequestFromJson(json);
}

@freezed
class ImageSearchRequest with _$ImageSearchRequest {
  const factory ImageSearchRequest({
    required String sessionId,
    required String imageUrl,
    @Default(20) int topK,
  }) = _ImageSearchRequest;

  factory ImageSearchRequest.fromJson(Map<String, dynamic> json) =>
      _$ImageSearchRequestFromJson(json);
}
