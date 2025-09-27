import 'package:freezed_annotation/freezed_annotation.dart';
part 'reset_password_request.freezed.dart';
part 'reset_password_request.g.dart';

@freezed
class ResetPasswordRequest with _$ResetPasswordRequest {
  const factory ResetPasswordRequest({
    required String email,
    @JsonKey(name: 'otpCode') required String otpCode,
    @JsonKey(name: 'newPassword') required String newPassword,
    @JsonKey(name: 'confirmNewPassword') required String confirmNewPassword,
  }) = _ResetPasswordRequest;
  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);
}
