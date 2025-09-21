import 'package:result_dart/result_dart.dart';

import '../../../../core/data/remote/base/api_error.dart';

abstract class SettingsRepository {
  Future<void> logout();
}
