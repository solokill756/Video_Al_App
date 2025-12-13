import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_state.freezed.dart';

/// 🎨 **PaymentState** - State machine cho payment flow
///
/// States:
/// - Initial: Trước khi user bấm Subscribe
/// - Loading: Đang lấy QR code từ backend
/// - PaymentLinkReceived: Nhận được QR code, hiển thị modal
/// - WaitingForPayment: Đã kết nối socket, chờ user thực hiện thanh toán
/// - PaymentSuccess: Nhận được paymentSuccess event từ backend
/// - PaymentError: Lỗi trong quá trình payment
///
/// State Flow:
/// ```
/// Initial
///    ↓
/// Loading (gọi API lấy QR code)
///    ↓
/// PaymentLinkReceived (hiển thị modal với QR code)
///    ↓
/// WaitingForPayment (connect socket, chờ thanh toán)
///    ↓
/// PaymentSuccess (nhận event từ socket) → Reset to Initial
///    ↓ (nếu lỗi)
/// PaymentError → Reset to Initial
/// ```
@freezed
class PaymentState with _$PaymentState {
  /// 🟡 **Initial State** - Trạng thái ban đầu
  ///
  /// Khi app khởi động hoặc sau khi payment hoàn thành
  const factory PaymentState.initial() = _Initial;

  /// 🔄 **Loading State** - Đang lấy payment link
  ///
  /// Trigger: User bấm "Subscribe" button
  /// Duration: ~1-2 giây
  /// UI: Show loading spinner, disable button
  const factory PaymentState.loading() = _Loading;

  /// ✅ **PaymentLinkReceived State** - Nhận được QR code
  ///
  /// Trigger: API trả về registrationLink thành công
  /// Data:
  ///   - paymentInfo: Parsed info từ QR link (account, bank, amount, description)
  ///   - planId: ID của gói dịch vụ
  ///   - planName: Tên gói dịch vụ (BASIC, PREMIUM, etc)
  /// UI:
  ///   - Hiển thị payment modal
  ///   - QR code image
  ///   - Payment details (account, bank, amount, description)
  ///   - Copy buttons cho mỗi field
  ///   - Status: "Đang chờ thanh toán..."
  const factory PaymentState.paymentLinkReceived({
    required String registrationLink,
    required String planId,
    required String planName,
  }) = _PaymentLinkReceived;

  /// ⏳ **WaitingForPayment State** - Chờ user thực hiện thanh toán
  ///
  /// Trigger: Modal hiển thị, connect socket thành công
  /// Socket Status: Connected, listening for 'paymentSuccess' event
  /// Duration: Có thể kéo dài nếu user chưa thanh toán
  /// UI:
  ///   - Keep modal open
  ///   - Loading indicator hoặc countdown
  ///   - Warning: "Chờ thanh toán..."
  ///   - Allow user đóng modal để thử lại sau
  const factory PaymentState.waitingForPayment({
    required String planId,
  }) = _WaitingForPayment;

  /// ✨ **PaymentSuccess State** - Thanh toán thành công!
  ///
  /// Trigger: Backend emit 'paymentSuccess' event qua socket
  /// Verification: Backend đã verify transaction (số tiền, nội dung, etc)
  /// Data:
  ///   - subscription: Thông tin subscription được kích hoạt
  ///   - message: Success message
  /// UI:
  ///   - Show success toast: "🎉 Thanh toán thành công!"
  ///   - Refetch user profile (cập nhật plan info)
  ///   - Đóng modal sau 2 giây
  ///   - Navigate tới /video-management
  /// Duration: Chuyển sang khác state sau 2-3 giây
  const factory PaymentState.paymentSuccess({
    required String message,
    Map<String, dynamic>? subscription,
  }) = _PaymentSuccess;

  /// ❌ **PaymentError State** - Lỗi trong quá trình payment
  ///
  /// Possible Errors:
  /// - API Error:
  ///   - "Plan not found" (404)
  ///   - "Unauthorized" (401)
  ///   - "Server error" (500)
  /// - Socket Error:
  ///   - "Connection failed"
  ///   - "Connection timeout"
  ///   - "Token invalid"
  /// - User Error:
  ///   - "Timeout": Thanh toán không được xác nhận trong 10 phút
  ///   - "Cancelled": User đóng modal
  ///
  /// UI:
  ///   - Show error toast
  ///   - Display error message
  ///   - "Retry" button
  ///   - "Contact support" option
  /// Recovery: User có thể retry hoặc contact support
  const factory PaymentState.paymentError({
    required String error,
    String? errorCode,
  }) = _PaymentError;
}
