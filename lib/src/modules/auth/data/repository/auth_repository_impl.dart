import 'package:injectable/injectable.dart';
import 'package:result_dart/result_dart.dart';

import '../../../../core/data/remote/base/api_error.dart';
import '../../../../core/data/remote/base/api_response.dart';
import '../../../../core/data/remote/services/api_service.dart';
import '../../../../core/data/local/storage.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/reset_password_request.dart';
import '../models/send_otp_request.dart';
import '../remote/auth_api_service.dart';
import '../../domain/repository/auth_repository.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _authApiService;

  AuthRepositoryImpl(this._authApiService);

  @override
  Future<Result<LoginResponse, ApiError>> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequest(email: email, password: password);

    final result =
        await _authApiService.login(request).tryGet((response) => response);

    // Lưu token vào storage khi login thành công
    await result.fold(
      (loginResponse) async {
        await Storage.setAccessToken(loginResponse.accessToken);
        await Storage.setRefreshToken(loginResponse.refreshToken);
        return loginResponse;
      },
      (error) async {
        return error;
      },
    );

    return result;
  }

  @override
  Future<Result<LoginResponse, ApiError>> refreshToken() async {
    final refreshToken = await Storage.refreshToken;
    if (refreshToken == null) {
      return Failure(ApiError.unauthorized('No refresh token found'));
    }

    final result = await _authApiService.refreshToken(
        {'refreshToken': refreshToken}).tryGet((response) => response);

    // Cập nhật token mới
    await result.fold(
      (loginResponse) async {
        await Storage.setAccessToken(loginResponse.accessToken);
        await Storage.setRefreshToken(loginResponse.refreshToken);
        return loginResponse;
      },
      (error) async {
        return error;
      },
    );

    return result;
  }

  @override
  Future<Result<StatusApiResponse, ApiError>> register({
    required RegisterRequest request,
  }) async {
    return _authApiService.register(request).tryGet((response) => response);
  }

  @override
  Future<Result<StatusApiResponse, ApiError>> sendOtp({
    required String email,
    String type = 'REGISTER',
  }) async {
    final request = SendOtpRequest(email: email, type: type);
    return await _authApiService
        .sendOtp(request)
        .tryGet((response) => response);
  }

  @override
  Future<Result<StatusApiResponse, ApiError>> resetPassword(
      ResetPasswordRequest request) async {
    return await _authApiService
        .resetPassword(request)
        .tryGet((response) => response);
  }
}
