import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dmvgenie/src/common/utils/formats.dart';
import 'package:dmvgenie/src/core/data/remote/base/api_response.dart';
import 'package:dmvgenie/src/core/data/remote/services/api_service.dart';
import 'package:injectable/injectable.dart';
import 'package:mime/mime.dart';
import 'package:result_dart/result_dart.dart';

import '../../../../core/data/local/storage.dart';
import '../../../../core/data/remote/base/api_error.dart';
import '../../domain/repository/settings_repository.dart';
import '../model/user_profile_model.dart';

@Injectable(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final Dio _dio;
  SettingsRepositoryImpl(this._dio);

  @override
  Future<void> logout() async {
    await Storage.removeAccessToken();
    await Storage.removeRefreshToken();
  }

  @override
  Future<Result<UserProfileModel, ApiError>> getCurrentUser() async {
    return await _dio
        .get('/profile')
        .tryGet((response) => UserProfileModel.fromJson(response.data));
  }

  @override
  Future<Result<UserProfileModel, ApiError>> updateProfile({
    String? name,
    String? phoneNumber,
    String? avatar,
  }) {
    final dataRequest = {
      'name': name,
      'phoneNumber': phoneNumber,
      'avatar': avatar,
    };
    final cleanData = Formats.filterNullOrEmpty(dataRequest);
    return _dio
        .put('/profile', data: cleanData)
        .tryGet((response) => UserProfileModel.fromJson(response.data));
  }

  @override
  Future<Result<UserProfileModel, ApiError>> uploadAvatar(
      {required String filePath}) async {
    final presignedUrlResult =
        await _dio.post('/profile/presigned-url-upload-avatar', data: {
      'fileName': filePath,
      'type': 'upload',
    }).tryGet((response) => response.data['url'] as String);
    return await presignedUrlResult.fold((uploadUrl) async {
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();
      final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
      final uploadDio = Dio();
      await uploadDio.put(
        uploadUrl,
        data: fileBytes,
        options: Options(
          headers: {
            'Content-Type': mimeType,
            'Content-Length': fileBytes.length,
          },
          receiveTimeout: null,
          sendTimeout: null,
        ),
      );
      return await updateProfile(avatar: uploadUrl.split('?').first);
    }, (error) async {
      return error.toFailure();
    });
  }

  @override
  Future<Result<StatusApiResponse, ApiError>> disable2FA(
      {required String otpCode}) {
    final data = {
      'totpCode': otpCode,
    };
    return _dio.post('/auth/disable-2fa', data: data).tryGet((response) {
      print('Response data: ${response.data}');
      return StatusApiResponse(
          message: response.data['message'] as String,
          statusCode: response.statusCode!);
    });
  }

  @override
  Future<Result<StatusApiResponse, ApiError>> enable2FA(
      {required String otpCode}) {
    final data = {
      'totpCode': otpCode,
    };
    return _dio.post('/auth/enable-2fa', data: data).tryGet((response) {
      print('Response data: ${response.data}');
      return StatusApiResponse(
          message: response.data['message'] as String,
          statusCode: response.statusCode!);
    });
  }

  @override
  Future<Result<String, ApiError>> getLinkFor2FA() {
    return _dio
        .post('/auth/get-link-2fa')
        .tryGet((response) => response.data['uri'] as String);
  }

  @override
  Future<Result<bool, ApiError>> verify2FA({required String otpCode}) {
    final data = {
      'totpCode': otpCode,
    };
    return _dio
        .post('/auth/verify-2fa', data: data)
        .tryGet((response) => response.data['success'] as bool);
  }

  @override
  Future<Result<UserProfileModel, ApiError>> removeAvatar() {
    final dataRequest = {
      'avatar': null,
    };
    return _dio
        .put('/profile', data: dataRequest)
        .tryGet((response) => UserProfileModel.fromJson(response.data));
  }

  @override
  Future<Result<StatusApiResponse, ApiError>> changePassword(
      {required String currentPassword,
      required String newPassword,
      required String confirmPassword}) {
    final data = {
      'password': currentPassword,
      'newPassword': newPassword,
      'confirmNewPassword': confirmPassword,
    };
    return _dio.put('/profile/change-password', data: data).tryGet((response) {
      return StatusApiResponse(
          message: response.data['message'] as String,
          statusCode: response.statusCode!);
    });
  }
}
