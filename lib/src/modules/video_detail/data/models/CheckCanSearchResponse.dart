import 'package:freezed_annotation/freezed_annotation.dart';

part 'CheckCanSearchResponse.freezed.dart';
part 'CheckCanSearchResponse.g.dart';

@freezed
class CheckCanSearchResponse with _$CheckCanSearchResponse {
  const factory CheckCanSearchResponse({
    required String statusCode,
    required String message,
  }) = _CheckCanSearchResponse;

  factory CheckCanSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckCanSearchResponseFromJson(json);
}
