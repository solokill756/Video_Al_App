import 'package:dmvgenie/src/modules/auth/data/models/register_request.dart';
import 'package:result_dart/result_dart.dart';

import '../../../../core/data/remote/base/api_error.dart';
import '../../../../core/data/remote/base/api_response.dart';
import '../../data/models/login_response.dart';

abstract class AuthRepository {
  Future<Result<LoginResponse, ApiError>> login({
    required String email,
    required String password,
  });

  Future<Result<LoginResponse, ApiError>> refreshToken();

  Future<Result<StatusApiResponse, ApiError>> sendOtp({
    required String email,
    String type = 'REGISTER',
  });

  Future<Result<StatusApiResponse, ApiError>> register({
    required RegisterRequest request,
  });
}
