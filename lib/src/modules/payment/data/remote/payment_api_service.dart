import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

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

  @POST('/payment/link-registration')
  Future<PaymentLinkResponse> getPaymentLink({
    @Body() required PaymentLinkRequest body,
  });
}
