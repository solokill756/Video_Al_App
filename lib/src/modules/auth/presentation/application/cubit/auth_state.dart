import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/data/remote/base/api_error.dart';
import '../../../../../core/data/remote/base/api_response.dart';
import '../../../data/models/login_response.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.loadingRegister() = _LoadingRegister;
  const factory AuthState.loginSuccess(LoginResponse loginResponse) =
      _LoginSuccess;
  const factory AuthState.error(String message) = _Error;
  const factory AuthState.validationError(ApiError apiError) =
      _AuthValidationError;
  const factory AuthState.sendOtpSuccess(StatusApiResponse sendOtpResponse) =
      _SendOtpSuccess;
  const factory AuthState.registerSuccess(StatusApiResponse registerResponse) =
      _RegisterSuccess;
}
