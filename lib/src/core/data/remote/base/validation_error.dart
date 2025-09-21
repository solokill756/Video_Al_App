import 'package:freezed_annotation/freezed_annotation.dart';

part 'validation_error.freezed.dart';
part 'validation_error.g.dart';

@freezed
class ValidationError with _$ValidationError {
  const factory ValidationError({
    required String field,
    required String message,
  }) = _ValidationError;

  factory ValidationError.fromJson(Map<String, dynamic> json) =>
      _$ValidationErrorFromJson(json);
}

@freezed
class ValidationErrorResponse with _$ValidationErrorResponse {
  const factory ValidationErrorResponse({
    required int statusCode,
    required List<ValidationError> message,
  }) = _ValidationErrorResponse;

  factory ValidationErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ValidationErrorResponseFromJson(json);
}
