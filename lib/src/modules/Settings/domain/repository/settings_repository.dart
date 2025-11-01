import 'package:dmvgenie/src/core/data/remote/base/api_response.dart';
import 'package:result_dart/result_dart.dart';

import '../../../../core/data/remote/base/api_error.dart';
import '../../data/model/user_profile_model.dart';

abstract class SettingsRepository {
  Future<void> logout();
  Future<Result<UserProfileModel, ApiError>> getCurrentUser();
  Future<Result<UserProfileModel, ApiError>> updateProfile(
      {String? name, String? phoneNumber, String? avatar});
  Future<Result<UserProfileModel, ApiError>> uploadAvatar(
      {required String filePath});
  Future<Result<UserProfileModel, ApiError>> removeAvatar();
  Future<Result<String, ApiError>> getLinkFor2FA();
  Future<Result<StatusApiResponse, ApiError>> enable2FA(
      {required String otpCode});
  Future<Result<StatusApiResponse, ApiError>> disable2FA(
      {required String otpCode});
  Future<Result<bool, ApiError>> verify2FA({required String otpCode});
  Future<Result<StatusApiResponse, ApiError>> changePassword(
      {required String currentPassword,
      required String newPassword,
      required String confirmPassword});
}
