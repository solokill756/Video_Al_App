import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_error.freezed.dart';
part 'api_error.g.dart';

// Validation Error models
@freezed
class ValidationErrorDetail with _$ValidationErrorDetail {
  const factory ValidationErrorDetail({
    required String field,
    required String message,
  }) = _ValidationErrorDetail;

  factory ValidationErrorDetail.fromJson(Map<String, dynamic> json) =>
      _$ValidationErrorDetailFromJson(json);
}

@freezed
class ApiError with _$ApiError implements Exception {
  factory ApiError(int? code, String message) = _ApiError;
  factory ApiError.server({int? code, required String message}) = _Server;
  factory ApiError.network({int? code, required String message}) = _Network;
  factory ApiError.unexpected() = _Unexpected;
  factory ApiError.unauthorized(String message) = _Unauthorized;
  factory ApiError.validation({
    required int statusCode,
    required List<ValidationErrorDetail> errors,
  }) = _Validation;

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);

  ApiError._();

  String get message {
    return maybeWhen(
      (code, message) => message,
      server: (code, message) => message,
      network: (_, message) => message,
      unauthorized: (message) => message,
      validation: (statusCode, errors) {
        if (errors.isNotEmpty) {
          // Trả về message của error đầu tiên
          return errors.first.message;
        }
        return "Validation error";
      },
      orElse: () => "Error unexpected",
    );
  }

  String get title => maybeWhen(
        (code, message) => "Error",
        unauthorized: (message) => "Error unauthorized",
        network: (code, __) => code == HttpStatus.internalServerError
            ? "Error internal server"
            : "Error",
        validation: (_, __) => "Validation Error",
        orElse: () => "Error",
      );

  // Helper method để lấy validation errors
  List<ValidationErrorDetail> get validationErrors => maybeWhen(
        (code, message) => <ValidationErrorDetail>[],
        validation: (_, errors) => errors,
        orElse: () => [],
      );

  // Helper method để lấy validation error cho một field cụ thể
  String? getValidationError(String field) {
    return maybeWhen(
      (code, message) => null,
      validation: (_, errors) {
        final error = errors.firstWhere(
          (e) => e.field == field,
          orElse: () => const ValidationErrorDetail(field: '', message: ''),
        );
        return error.message.isNotEmpty ? error.message : null;
      },
      orElse: () => null,
    );
  }
}
