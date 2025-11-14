import 'package:dmvgenie/src/modules/payment/data/model/payment_model.dart';

/// 📋 **PaymentRepository** - Abstract repository cho payment logic
///
/// Pattern: Repository Pattern (Abstract interface)
/// Responsibility: Define contracts cho payment operations
/// Implementation: PaymentRepositoryImpl
///
/// Architecture Benefits:
/// - ✅ Separation of concerns: UI layer không biết về API details
/// - ✅ Easy testing: Mock repository trong unit tests
/// - ✅ Easy to change: Thay đổi implementation mà không ảnh hưởng UI
///
/// Flow:
/// 1. UI -> Cubit -> Repository -> API/Socket
/// 2. Response trở lại qua layers
abstract class PaymentRepository {
  /// 🎫 **getPaymentLink** - Lấy QR code thanh toán
  ///
  /// Purpose: Generate QR code payment link từ backend
  ///
  /// Parameters:
  ///   - planId: ID của gói dịch vụ user muốn subscribe
  ///
  /// Returns: PaymentLinkResponse chứa URL QR code
  ///
  /// Exceptions:
  ///   - Throws nếu user không login (401)
  ///   - Throws nếu plan không tìm thấy (404)
  ///   - Throws nếu backend error (500)
  ///
  /// Example:
  /// ```dart
  /// final response = await paymentRepository.getPaymentLink(planId: 5);
  /// // response.registrationLink = "https://qr.sepay.vn/img?acc=..."
  /// ```
  Future<PaymentLinkResponse> getPaymentLink({
    required int planId,
  });

  /// 💬 **registerPaymentSuccessListener** - Setup listener cho payment success
  ///
  /// Connect tới Socket.IO server và listen cho event 'paymentSuccess'
  ///
  /// Parameters:
  ///   - onSuccess: Callback khi thanh toán thành công
  ///   - onError: Callback khi có lỗi
  ///
  /// Example:
  /// ```dart
  /// paymentRepository.registerPaymentSuccessListener(
  ///   onSuccess: (data) {
  ///     print('Payment success: $data');
  ///     // Update plan, show success message, redirect
  ///   },
  ///   onError: (error) {
  ///     print('Payment error: $error');
  ///   },
  /// );
  /// ```
  Future<void> registerPaymentSuccessListener({
    required Function(Map<String, dynamic> data) onSuccess,
    Function(String error)? onError,
  });

  /// 🔌 **unregisterPaymentListener** - Cleanup socket listener
  ///
  /// Gọi khi modal đóng hay user navigate away
  /// Prevent memory leak bằng cách remove listeners và disconnect socket
  Future<void> unregisterPaymentListener();
}
