import 'package:injectable/injectable.dart';
import 'package:dmvgenie/src/modules/payment/data/model/payment_model.dart';
import 'package:dmvgenie/src/modules/payment/data/remote/payment_api_service.dart';
import 'package:dmvgenie/src/modules/payment/data/remote/payment_socket_service.dart';
import 'package:dmvgenie/src/modules/payment/domain/repository/payment_repository.dart';
import '../../../../common/utils/app_environment.dart';
import '../../../../core/data/local/storage.dart';

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

      // Get base URL từ environment config
      // Remove '/api' suffix for socket connection
      var baseUrl = AppEnvironment.apiUrl;
      if (baseUrl.isEmpty) {
        throw Exception('API URL is not configured in .env file');
      }

      // Remove '/api' from URL if present (socket doesn't need it)
      if (baseUrl.endsWith('/api')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 4);
      } else if (baseUrl.endsWith('/api/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 5);
      }

      // Get auth token từ secure storage
      final accessToken = await Storage.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Access token not found. Please login first.');
      }
      final token = 'Bearer $accessToken';

      print('🔌🔌🔌 Socket config:');
      print('  - baseUrl: $baseUrl');
      print('  - token: ${token.substring(0, 20)}...');
      print('  - Full token length: ${token.length}');

      // Register error callback nếu có
      if (onError != null) {
        _paymentSocketService.onPaymentError((error) {
          print('❌❌❌ Payment socket error callback: $error');
          onError(error);
        });

        _paymentSocketService.onConnectError((error) {
          print('❌❌❌ Socket connection error callback: $error');
          onError(error);
        });
      }

      // Register success callback
      _paymentSocketService.onPaymentSuccess((data) {
        print('✅✅✅ PaymentRepository: Payment success event received!');
        print('   Data: $data');
        print('   Data type: ${data.runtimeType}');
        onSuccess(data);
        print('✅✅✅ PaymentRepository: onSuccess callback executed');
      });

      // Register connect callback để debug
      _paymentSocketService.onConnect(() {
        print('✅✅✅ PaymentRepository: Socket connected successfully!');
      });

      // Connect tới socket server
      print('🔌🔌🔌 Connecting to socket server...');
      await _paymentSocketService.connect(
        baseUrl: baseUrl,
        token: token,
      );

      print('✅✅✅ Payment listener registered and socket connection initiated');
      print('   Waiting for socket connection...');
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
