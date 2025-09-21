import 'package:dio/dio.dart';
import '../base/api_error.dart';

class ErrorInterceptor extends InterceptorsWrapper {
  bool isRefreshing = false;
  bool isShowingExpireTokenDialog = false;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is Map<String, dynamic>) {
      final responseData = response.data as Map<String, dynamic>;

      // Xử lý validation errors (status 400 với array message)
      if (response.statusCode == 400 && responseData['message'] is List) {
        final List<dynamic> messageList = responseData['message'];
        final List<ValidationErrorDetail> validationErrors = messageList
            .map((e) =>
                ValidationErrorDetail.fromJson(e as Map<String, dynamic>))
            .toList();

        throw ApiError.validation(
          statusCode: responseData['statusCode'] ?? 400,
          errors: validationErrors,
        );
      }

      // Xử lý các lỗi server khác
      final error = responseData['error'];
      if (error != null) {
        throw ApiError.server(
          code: error['code'],
          message: error['message'],
        );
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      //log out
    } else {
      handler.next(err);
    }
  }
}
