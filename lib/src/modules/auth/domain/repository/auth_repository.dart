import 'package:result_dart/result_dart.dart';

import '../../../../core/data/remote/base/api_error.dart';
import '../../data/models/login_response.dart';

abstract class AuthRepository {
  Future<Result<LoginResponse, ApiError>> login({
    required String email,
    required String password,
  });

  Future<Result<LoginResponse, ApiError>> refreshToken();

  Future<Result<Unit, ApiError>> register({
    required String name,
    required String email,
    required String password,
  });
}
