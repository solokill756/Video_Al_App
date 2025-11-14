import 'package:injectable/injectable.dart';
import 'package:dmvgenie/src/modules/payment/data/model/payment_model.dart';
import 'package:dmvgenie/src/modules/payment/data/remote/payment_api_service.dart';
import 'package:dmvgenie/src/modules/payment/data/remote/payment_socket_service.dart';
import 'package:dmvgenie/src/modules/payment/domain/repository/payment_repository.dart';

/// 🔧 **PaymentRepositoryImpl** - Concrete implementation của PaymentRepository
///
/// Responsibilities:
/// 1. Gọi PaymentApiService để lấy QR code link
/// 2. Quản lý PaymentSocketService để listen payment success events
/// 3. Transform/map data từ API thành domain models
///
/// Architecture:
/// ```
/// UI (Cubit)
///    ↓
/// PaymentRepository (Interface)
///    ↓
/// PaymentRepositoryImpl
///    ├→ PaymentApiService (REST API)
///    └→ PaymentSocketService (WebSocket)
/// ```
@Injectable(as: PaymentRepository)
class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentApiService _paymentApiService;
  final PaymentSocketService _paymentSocketService;

  PaymentRepositoryImpl({
    required PaymentApiService paymentApiService,
    required PaymentSocketService paymentSocketService,
  })  : _paymentApiService = paymentApiService,
        _paymentSocketService = paymentSocketService;

  /// 🎫 **getPaymentLink** - Lấy QR code thanh toán từ backend
  ///
  /// Flow:
  /// 1. Gọi API endpoint: POST /payment/link-registration
  /// 2. Pass planId trong body
  /// 3. Backend tạo QR code qua SePayVN gateway
  /// 4. Trả về registration link (URL)
  /// 5. Frontend parse URL để extract payment info
  ///
  /// Example Response:
  /// ```
  /// {
  ///   "registrationLink": "https://qr.sepay.vn/img?acc=888852690888&bank=VietinBank&amount=4000&des=SEVQR%20DHXXX1XXX5"
  /// }
  /// ```
  ///
  /// Parse logic:
  /// - acc: Số tài khoản nhận tiền
  /// - bank: Ngân hàng
  /// - amount: Số tiền (VND)
  /// - des: Nội dung chuyển khoản (QUAN TRỌNG - phải nhập chính xác)
  @override
  Future<PaymentLinkResponse> getPaymentLink({
    required int planId,
  }) async {
    try {
      print('🔄 Getting payment link for plan ID: $planId');

      // Tạo request body
      final request = PaymentLinkRequest(planId: planId);

      // Gọi API
      final response = await _paymentApiService.getPaymentLink(body: request);

      print('✅ Payment link received: ${response.registrationLink}');
      return response;
    } catch (e) {
      print('❌ Error getting payment link: $e');
      rethrow;
    }
  }

  /// 💬 **registerPaymentSuccessListener** - Setup real-time payment listener
  ///
  /// Flow:
  /// 1. Get base URL từ environment config
  /// 2. Get auth token từ secure storage
  /// 3. Connect socket tới backend
  /// 4. Register callback cho event 'paymentSuccess'
  /// 5. Backend emit event khi thanh toán được verify
  ///
  /// Important:
  /// - Socket connection phải có valid Bearer token
  /// - Backend verify transaction before emit success event
  /// - Event data có thể chứa subscription info mới
  ///
  /// Error Scenarios:
  /// - Connection failed: onError callback
  /// - Socket disconnected: Auto-reconnect by socket.io
  /// - Invalid token: Connection failed
  ///
  /// Example Data khi payment success:
  /// ```json
  /// {
  ///   "status": "success",
  ///   "subscription": {
  ///     "id": 123,
  ///     "planId": 5,
  ///     "userId": 456,
  ///     "startDate": "2025-11-12",
  ///     "endDate": "2026-11-12",
  ///     "isActive": true
  ///   }
  /// }
  /// ```
  @override
  Future<void> registerPaymentSuccessListener({
    required Function(Map<String, dynamic> data) onSuccess,
    Function(String error)? onError,
  }) async {
    try {
      print('🔌 Registering payment success listener...');

      // TODO: Get base URL từ environment config
      // const baseUrl = 'http://localhost:3000';

      // TODO: Get auth token từ auth cubit hoặc secure storage
      // final token = 'Bearer ...';

      // Tạm thời mock URL và token
      const baseUrl = 'http://localhost:3000';
      const token = 'Bearer mock-token';

      // Register error callback nếu có
      if (onError != null) {
        _paymentSocketService.onPaymentError((error) {
          print('❌ Payment socket error: $error');
          onError(error);
        });

        _paymentSocketService.onConnectError((error) {
          print('❌ Socket connection error: $error');
          onError(error);
        });
      }

      // Register success callback
      _paymentSocketService.onPaymentSuccess((data) {
        print('✅ Payment success event received: $data');
        onSuccess(data);
      });

      // Connect tới socket server
      await _paymentSocketService.connect(
        baseUrl: baseUrl,
        token: token,
      );

      print('✅ Payment listener registered');
    } catch (e) {
      print('❌ Error registering payment listener: $e');
      onError?.call(e.toString());
      rethrow;
    }
  }

  /// 🔌 **unregisterPaymentListener** - Cleanup socket connection
  ///
  /// Cleanup process:
  /// 1. Remove event listeners
  /// 2. Disconnect từ socket server
  /// 3. Release resources
  ///
  /// Gọi khi:
  /// - User đóng payment modal
  /// - User navigate away từ payment page
  /// - Payment complete (sau khi receive success event)
  ///
  /// Purpose: Prevent memory leak và socket connection pool exhaustion
  @override
  Future<void> unregisterPaymentListener() async {
    try {
      print('🔌 Disconnecting payment socket...');

      // Disconnect socket
      await _paymentSocketService.disconnect();

      print('✅ Payment socket disconnected');
    } catch (e) {
      print('❌ Error unregistering payment listener: $e');
      rethrow;
    }
  }
}
