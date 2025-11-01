import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/data/local/storage.dart';
import '../../../../core/data/remote/base/api_response.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/reset_password_request.dart';
import '../models/send_otp_request.dart';

@injectable
class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  /// Login với email và password
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      '/auth/login',
      data: request.toJson(),
    );

    final loginResponse = LoginResponse.fromJson(response.data);

    // Tự động lưu tokens sau khi login thành công
    await Storage.setAccessToken(loginResponse.accessToken);
    await Storage.setRefreshToken(loginResponse.refreshToken);

    return loginResponse;
  }

  /// Register tài khoản mới
  Future<StatusApiResponse> register(RegisterRequest request) async {
    final response = await _dio.post(
      '/auth/register',
      data: request.toJson(),
    );
    final responseData = response.data as Map<String, dynamic>;
    final message =
        responseData['message'] as String? ?? 'Registration successful';
    return StatusApiResponse(
      message: message,
      statusCode: response.statusCode!,
    );
  }

  /// Refresh token để lấy access token mới
  Future<LoginResponse> refreshToken(
    Map<String, String> request,
  ) async {
    final response = await _dio.post(
      '/auth/refresh',
      data: request,
    );

    final loginResponse = LoginResponse.fromJson(response.data);

    // Tự động cập nhật tokens mới
    await Storage.setAccessToken(loginResponse.accessToken);
    await Storage.setRefreshToken(loginResponse.refreshToken);

    return loginResponse;
  }

  /// Forgot password - gửi email reset password
  /// Không cần Authorization header
  Future<StatusApiResponse> forgotPassword(String email) async {
    final response = await _dio.post(
      '/auth/forgot-password',
      data: {'email': email},
    );
    return StatusApiResponse.fromJson(response.data);
  }

  /// Change password cho user đã login
  /// Cần Authorization header
  Future<StatusApiResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _dio.post(
      '/auth/change-password',
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
    return StatusApiResponse.fromJson(response.data);
  }

  /// Verify email với toke
  Future<StatusApiResponse> verifyEmail(String token) async {
    final response = await _dio.post(
      '/auth/verify-email',
      data: {'token': token},
    );
    return StatusApiResponse.fromJson(response.data);
  }

  /// Resend email verification
  Future<StatusApiResponse> resendEmailVerification() async {
    final response = await _dio.post('/auth/resend-verification');
    return StatusApiResponse.fromJson(response.data);
  }

  // Gửi OTP đến email
  Future<StatusApiResponse> sendOtp(SendOtpRequest request) async {
    final response = await _dio.post(
      '/auth/otp',
      data: request.toJson(),
    );

    // Parse response data
    final responseData = response.data as Map<String, dynamic>;
    final message =
        responseData['message'] as String? ?? 'OTP sent successfully';

    return StatusApiResponse(
      message: message,
      statusCode: response.statusCode!,
    );
  }

  // Reset password với OTP
  Future<StatusApiResponse> resetPassword(ResetPasswordRequest request) async {
    final response = await _dio.post(
      '/auth/forgot-password',
      data: request.toJson(),
    );
    final responseData = response.data as Map<String, dynamic>;
    final message =
        responseData['message'] as String? ?? 'Password reset successfully';
    return StatusApiResponse(
      message: message,
      statusCode: response.statusCode!,
    );
  }

  Future<StatusApiResponse> verify2FA({required String otpCode}) async {
    final response = await _dio.post(
      '/auth/verify-2fa',
      data: {'totpCode': otpCode},
    );
    final responseData = response.data as Map<String, dynamic>;
    final message =
        responseData['message'] as String? ?? '2FA verified successfully';
    return StatusApiResponse(
      message: message,
      statusCode: response.statusCode!,
    );
  }
}
