import 'package:injectable/injectable.dart';
import 'package:result_dart/result_dart.dart';

import '../../../../core/data/local/storage.dart';
import '../../../../core/data/remote/base/api_error.dart';
import '../../../auth/data/remote/auth_api_service.dart';
import '../../domain/repository/settings_repository.dart';

@Injectable(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final AuthApiService _authApiService;
  SettingsRepositoryImpl(this._authApiService);

  @override
  Future<void> logout() async {
    await Storage.removeAccessToken();
    await Storage.removeRefreshToken();
  }
}
