import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dmvgenie/src/modules/payment/domain/repository/payment_repository.dart';
import 'package:dmvgenie/src/modules/payment/presentation/application/cubit/payment_state.dart';

/// 🎮 **PaymentCubit** - Business logic cho payment flow
///
/// Pattern: Cubit (subset của BLoC, tập trung vào state management)
/// Responsibility: Điều phối payment operations và state transitions
///
/// Methods:
/// - getPaymentLink: Gọi API để lấy QR code
/// - listenForPaymentSuccess: Connect socket và listen event
/// - cleanup: Disconnect socket khi modal đóng
///
/// State Management Flow:
/// ```
/// Initial
///    ↓ (user click Subscribe)
/// emit(Loading)
///    ↓ (API success)
/// emit(PaymentLinkReceived)
///    ↓ (modal opened, socket connected)
/// emit(WaitingForPayment)
///    ↓ (socket receive paymentSuccess)
/// emit(PaymentSuccess)
///    ↓
/// emit(Initial) after delay
/// ```

@injectable
class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository _paymentRepository;

  // 🔧 Config
  static const Duration _paymentTimeoutDuration = Duration(minutes: 10);

  PaymentCubit({
    required PaymentRepository paymentRepository,
  })  : _paymentRepository = paymentRepository,
        super(const PaymentState.initial());

  /// 🎫 **getPaymentLink** - Lấy QR code thanh toán
  ///
  /// Flow:
  /// 1. Emit Loading state
  /// 2. Gọi repository để fetch payment link từ API
  /// 3. Parse registrationLink để extract payment info
  /// 4. Emit PaymentLinkReceived state với parsed info
  /// 5. If error: emit PaymentError state
  ///
  /// Parameters:
  ///   - planId: ID của gói dịch vụ
  ///   - planName: Tên gói (BASIC, PREMIUM, etc)
  ///
  /// Exceptions:
  ///   - DioException: Network error, timeout, etc
  ///   - FormatException: URL parse error
  ///   - Generic Exception: Unexpected error
  ///
  /// Example:
  /// ```dart
  /// await paymentCubit.getPaymentLink(planId: 5, planName: "PREMIUM");
  /// // State changes: Initial → Loading → PaymentLinkReceived
  /// ```
  Future<void> getPaymentLink({
    required int planId,
    required String planName,
  }) async {
    try {
      // 1️⃣ Emit loading state
      print('📝 Getting payment link for plan: $planName (ID: $planId)');
      emit(const PaymentState.loading());

      // 2️⃣ Call repository API
      final response = await _paymentRepository.getPaymentLink(
        planId: planId,
      );

      // 3️⃣ Emit success state with payment link
      print('✅ Payment link received: ${response.registrationLink}');
      emit(
        PaymentState.paymentLinkReceived(
          registrationLink: response.registrationLink,
          planId: planId.toString(),
          planName: planName,
        ),
      );
    } catch (e) {
      // ❌ Handle error
      print('❌ Error getting payment link: $e');
      final errorMessage = _getErrorMessage(e);
      emit(PaymentState.paymentError(error: errorMessage));
    }
  }

  /// 💬 **listenForPaymentSuccess** - Setup listener cho payment success
  ///
  /// Flow:
  /// 1. Emit WaitingForPayment state
  /// 2. Call repository để connect socket
  /// 3. Register callback cho payment success event
  /// 4. If success event received: Emit PaymentSuccess
  /// 5. If socket error: Emit PaymentError
  ///
  /// Socket Events:
  /// - paymentSuccess: Triggered khi backend xác nhận thanh toán
  ///   Data: { status: "success", subscription: {...} }
  /// - connect_error: Socket connection failed
  /// - disconnect: Socket disconnected
  ///
  /// Timeout:
  /// - 10 phút: Nếu ko nhận được success, auto emit error
  ///
  /// Example:
  /// ```dart
  /// await paymentCubit.listenForPaymentSuccess(planId: 5);
  /// // Socket connects, waiting for payment...
  /// // When backend emit paymentSuccess → PaymentSuccess state
  /// ```
  Future<void> listenForPaymentSuccess({required int planId}) async {
    try {
      // 1️⃣ Emit waiting state
      print('⏳ Waiting for payment confirmation...');
      print('   Emitting: PaymentState.waitingForPayment(planId: $planId)');
      emit(PaymentState.waitingForPayment(planId: planId.toString()));
      print('   ✅ waitingForPayment state emitted!');

      // 2️⃣ Register payment success listener
      // This will setup socket connection và register callbacks
      await _paymentRepository.registerPaymentSuccessListener(
        // ✅ Success callback
        onSuccess: (data) {
          try {
            print('✨ Payment success received: $data');

            // Parse subscription từ socket event
            // Socket event có structure:
            // { "status": "success", "subscription": {...}, "message": "..." }
            Map<String, dynamic>? subscription;
            if (data.containsKey('subscription') &&
                data['subscription'] is Map) {
              subscription = Map<String, dynamic>.from(
                  data['subscription'] as Map<dynamic, dynamic>);
            }

            final message =
                data['message'] as String? ?? 'Thanh toán thành công!';

            // 🎉 Emit success state với subscription data
            emit(
              PaymentState.paymentSuccess(
                message: message,
                subscription: subscription,
              ),
            );

            // 🔄 Auto reset sau 3 giây
            Future.delayed(const Duration(seconds: 3), () {
              if (!isClosed) {
                emit(const PaymentState.initial());
              }
            });
          } catch (e) {
            print('❌ Error parsing payment success data: $e');
            // Fallback: emit success anyway
            emit(
              const PaymentState.paymentSuccess(
                message: 'Thanh toán thành công!',
                subscription: null,
              ),
            );
          }
        },
        // ❌ Error callback
        onError: (error) {
          print('❌ Payment socket error: $error');
          emit(PaymentState.paymentError(error: error));
        },
      );

      // 3️⃣ Setup timeout (10 minutes)
      Future.delayed(_paymentTimeoutDuration, () {
        if (!isClosed &&
            state.maybeWhen(
              waitingForPayment: (_) => true,
              orElse: () => false,
            )) {
          print('⏱️ Payment timeout (10 minutes)');
          emit(
            const PaymentState.paymentError(
              error:
                  'Thanh toán timeout. Vui lòng thử lại hoặc liên hệ hỗ trợ.',
              errorCode: 'PAYMENT_TIMEOUT',
            ),
          );
        }
      });
    } catch (e) {
      print('❌ Error setting up payment listener: $e');
      final errorMessage = _getErrorMessage(e);
      emit(PaymentState.paymentError(error: errorMessage));
    }
  }

  /// 🔌 **cleanup** - Cleanup socket connection
  ///
  /// Gọi khi user đóng payment modal
  /// Prevent memory leak bằng cách:
  /// - Remove socket listeners
  /// - Disconnect socket
  /// - Reset state
  ///
  /// Important: Gọi này ở trong useEffect/dispose của payment modal
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   paymentCubit.cleanup();
  ///   super.dispose();
  /// }
  /// ```
  Future<void> cleanup() async {
    try {
      print('🧹 Cleaning up payment resources...');

      // Unregister listeners và disconnect socket
      await _paymentRepository.unregisterPaymentListener();

      // Reset state
      if (!isClosed) {
        emit(const PaymentState.initial());
      }

      print('✅ Cleanup completed');
    } catch (e) {
      print('⚠️ Error during cleanup: $e');
    }
  }

  /// 🔄 **reset** - Manually reset state to initial
  ///
  /// Gọi để reset state mà không cleanup socket
  /// Dùng khi user retry sau lỗi
  void reset() {
    print('🔄 Resetting payment state');
    if (!isClosed) {
      emit(const PaymentState.initial());
    }
  }

  /// 📝 **_getErrorMessage** - Transform exception thành user-friendly message
  ///
  /// Maps technical errors thành Vietnamese messages
  /// Dùng trong error handling
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('401')) {
      return 'Vui lòng đăng nhập để tiếp tục';
    } else if (errorString.contains('404')) {
      return 'Gói dịch vụ không tìm thấy';
    } else if (errorString.contains('connection')) {
      return 'Lỗi kết nối. Vui lòng kiểm tra internet';
    } else if (errorString.contains('timeout')) {
      return 'Yêu cầu timeout. Vui lòng thử lại';
    } else {
      return 'Lỗi khi xử lý thanh toán: ${error.toString()}';
    }
  }
}
