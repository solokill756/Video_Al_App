import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

/// 📋 **PaymentLinkRequest** - Request để lấy payment link từ backend
///
/// Khi user nhấn "Subscribe", app gửi request này với `planId` của gói dịch vụ
/// Backend sẽ tạo QR code và trả về link
@freezed
class PaymentLinkRequest with _$PaymentLinkRequest {
  const factory PaymentLinkRequest({
    required int planId,
  }) = _PaymentLinkRequest;

  factory PaymentLinkRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentLinkRequestFromJson(json);
}

/// 📱 **PaymentLinkResponse** - Response khi lấy payment link từ backend
///
/// Chứa URL QR code từ SePayVN gateway
/// Format: https://qr.sepay.vn/img?acc=SO_TAI_KHOAN&bank=NGAN_HANG&amount=SO_TIEN&des=NOI_DUNG
@freezed
class PaymentLinkResponse with _$PaymentLinkResponse {
  const factory PaymentLinkResponse({
    required String registrationLink,
  }) = _PaymentLinkResponse;

  factory PaymentLinkResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentLinkResponseFromJson(json);
}

/// 💳 **PaymentInfo** - Thông tin thanh toán được parse từ QR link
///
/// Parse từ URL của QR code để hiển thị chi tiết payment:
/// - Ngân hàng nhận tiền
/// - Số tài khoản
/// - Số tiền cần chuyển
/// - Nội dung chuyển khoản (QUAN TRỌNG - phải chính xác 100%)
@freezed
class PaymentInfo with _$PaymentInfo {
  const factory PaymentInfo({
    /// Số tài khoản nhận tiền (ví dụ: 888852690888)
    required String accountNumber,

    /// Tên ngân hàng (ví dụ: VietinBank)
    required String bankName,

    /// Số tiền cần chuyển theo định dạng VND (ví dụ: "4000")
    required String amount,

    /// ⚠️ Nội dung chuyển khoản - PHẢI NHẬP CHÍNH XÁC 100%
    /// Backend dùng nội dung này để identify transaction
    /// Ví dụ: "SEVQR DHXXX1XXX5"
    required String description,

    /// URL QR code để quét bằng mobile banking app
    required String qrUrl,
  }) = _PaymentInfo;

  factory PaymentInfo.fromJson(Map<String, dynamic> json) =>
      _$PaymentInfoFromJson(json);
}

/// ✅ **PaymentSuccessData** - Data khi thanh toán thành công
///
/// Được emit từ backend qua Socket.IO event 'paymentSuccess'
/// Khi nhận được event này, frontend cập nhật UI và kích hoạt gói dịch vụ
@freezed
class PaymentSuccessData with _$PaymentSuccessData {
  const factory PaymentSuccessData({
    required String status, // "success"
    String? message,
    Map<String, dynamic>? subscription,
  }) = _PaymentSuccessData;

  factory PaymentSuccessData.fromJson(Map<String, dynamic> json) =>
      _$PaymentSuccessDataFromJson(json);
}

/// 🔗 **PaymentLinkDetails** - Tách rời các thành phần URL QR code
///
/// Utility model để dễ dàng extract thông tin từ URL
@freezed
class PaymentLinkDetails with _$PaymentLinkDetails {
  const factory PaymentLinkDetails({
    /// Ví dụ: "https://qr.sepay.vn/img"
    required String baseUrl,

    /// Các query parameters từ URL
    required Map<String, String> queryParams,
  }) = _PaymentLinkDetails;

  factory PaymentLinkDetails.fromJson(Map<String, dynamic> json) =>
      _$PaymentLinkDetailsFromJson(json);
}
