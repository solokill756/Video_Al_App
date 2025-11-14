import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/data/remote/base/api_response.dart';
import '../model/payment_model.dart';

part 'payment_api_service.g.dart';

/// 🔌 **PaymentApiService** - Retrofit service để gọi payment APIs
///
/// Xử lý tất cả các API calls liên quan đến payment:
/// - Lấy payment link QR code
/// - Verify transaction status
///
/// Architecture: Retrofit (code generation for REST APIs)
@injectable
@RestApi()
abstract class PaymentApiService {
  @factoryMethod
  factory PaymentApiService(Dio dio, {@Named('baseUrl') String? baseUrl}) =
      _PaymentApiService;

  /// 📝 **Lấy Payment Link - GET QR CODE**
  ///
  /// Endpoint: `POST /payment/link-registration`
  ///
  /// Purpose: Tạo QR code thanh toán cho việc đăng ký gói dịch vụ
  ///
  /// Parameters:
  ///   - body: Chứa `planId` của gói dịch vụ mà user muốn subscribe
  ///
  /// Returns:
  ///   - registrationLink: URL QR code từ SePayVN gateway
  ///   - Format: https://qr.sepay.vn/img?acc=888852690888&bank=VietinBank&amount=4000&des=SEVQR DHXXX1XXX5
  ///
  /// Example Response:
  /// ```json
  /// {
  ///   "registrationLink": "https://qr.sepay.vn/img?acc=888852690888&bank=VietinBank&amount=4000&des=SEVQR%20DHXXX1XXX5"
  /// }
  /// ```
  ///
  /// Error Handling:
  ///   - 400: Plan not found
  ///   - 401: Unauthorized (token invalid/expired)
  ///   - 500: Backend error
  @POST('/payment/link-registration')
  Future<PaymentLinkResponse> getPaymentLink({
    @Body() required PaymentLinkRequest body,
  });
}
