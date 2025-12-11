import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_model.freezed.dart';
part 'search_model.g.dart';

@Freezed(toJson: false)
class SearchResult with _$SearchResult {
  const factory SearchResult({
    required String imagePath,
    required String videoPath,
    required double score,
    required double ptsTime,
    required double fps,
    required int frameIdx,
  }) = _SearchResult;

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      imagePath: json['image_path'] as String? ?? '',
      videoPath: json['video_path'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      ptsTime: (json['pts_time'] as num?)?.toDouble() ?? 0.0,
      fps: (json['fps'] as num?)?.toDouble() ?? 0.0,
      frameIdx: (json['frame_idx'] as num?)?.toInt() ?? 0,
    );
  }
}

@Freezed(toJson: false)
class SearchResponse with _$SearchResponse {
  const factory SearchResponse({
    required String query,
    required int topK,
    required int totalIndexed,
    required List<SearchResult> results,
    required int tookMs,
  }) = _SearchResponse;

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      query: json['query'] as String? ?? '',
      topK: (json['top_k'] as num?)?.toInt() ?? 0,
      totalIndexed: (json['total_indexed'] as num?)?.toInt() ?? 0,
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tookMs: (json['took_ms'] as num?)?.toInt() ?? 0,
    );
  }
}

@freezed
class TextSearchRequest with _$TextSearchRequest {
  const factory TextSearchRequest({
    required String query,
    required int topK,
  }) = _TextSearchRequest;

  factory TextSearchRequest.fromJson(Map<String, dynamic> json) =>
      _$TextSearchRequestFromJson(json);
}

@freezed
class ImageSearchRequest with _$ImageSearchRequest {
  const factory ImageSearchRequest({
    @JsonKey(name: 'image_url') required String imageUrl,
    required int topK,
  }) = _ImageSearchRequest;

  factory ImageSearchRequest.fromJson(Map<String, dynamic> json) =>
      _$ImageSearchRequestFromJson(json);
}
