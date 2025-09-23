import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_request.freezed.dart';
part 'register_request.g.dart';

@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String email,
    required String password,
    @JsonKey(name: 'phoneNumber') required String phoneNumber,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'confirmPassword') required String confirmPassword,
    @JsonKey(name: 'otpCode') required String otpCode,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}
