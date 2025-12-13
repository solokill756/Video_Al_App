import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../common/utils/app_environment.dart';

@injectable
class TriggerPrivateSearchService {
  /// Trigger AI processing for private video search
  /// Fire-and-forget: không chờ response, không block user flow
  Future<void> triggerPrivateSearch() async {
    final triggerUrl = AppEnvironment.triggerPrivateSearchUrl;

    if (triggerUrl.isEmpty) {
      print('⚠️ TRIGGER_PRIVATE_SEARCH_URL is not set in .env file');
      return;
    }

    try {
      // Tạo Dio instance riêng cho trigger API (không dùng auth interceptor)
      final dio = Dio(
        BaseOptions(
          baseUrl: 'http://$triggerUrl',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      // Fire-and-forget: không await, không catch error để không block
      dio.post('/trigger').catchError((error) {
        // Silent fail - chỉ log, không throw
        print('⚠️ Failed to trigger private search (non-blocking): $error');
        return Response(
          requestOptions: RequestOptions(path: '/trigger'),
          statusCode: 500,
        );
      });

      print('✅ Private search trigger sent (fire-and-forget)');
    } catch (e) {
      // Silent fail - không ảnh hưởng user experience
      print('⚠️ Error triggering private search (non-blocking): $e');
    }
  }
}
