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

@Singleton()
class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository _paymentRepository;

  // 🔧 Config
  static const Duration _paymentTimeoutDuration = Duration(minutes: 10);

  PaymentCubit({
    required PaymentRepository paymentRepository,
  })  : _paymentRepository = paymentRepository,
        super(const PaymentState.initial());

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

  Future<void> listenForPaymentSuccess({required int planId}) async {
    print('🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌');
    print('🔌 PaymentCubit.listenForPaymentSuccess() CALLED!');
    print('   Plan ID: $planId');
    print('🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌🔌');

    try {
      // 1️⃣ Emit waiting state
      print('⏳ Step 1: Emitting waitingForPayment state...');
      print('   Plan ID: $planId');
      emit(PaymentState.waitingForPayment(planId: planId.toString()));
      print('   ✅✅✅ waitingForPayment state emitted successfully!');

      // 2️⃣ Register payment success listener
      // This will setup socket connection và register callbacks
      print('🔌🔌🔌 PaymentCubit: Registering payment success listener...');
      await _paymentRepository.registerPaymentSuccessListener(
        // ✅ Success callback
        onSuccess: (data) {
          try {
            print('✨✨✨ PaymentCubit: Payment success received!');
            print('   Data: $data');

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
            print('🎉🎉🎉 PaymentCubit: Emitting PaymentSuccess state');
            print('   Message: $message');
            print('   Subscription: $subscription');
            emit(
              PaymentState.paymentSuccess(
                message: message,
                subscription: subscription,
              ),
            );
            print(
                '✅✅✅ PaymentCubit: PaymentSuccess state emitted successfully!');

            // 🔄 Auto reset sau 5 giây (đủ thời gian để user thấy success message)
            // KHÔNG reset nếu modal đã đóng (để tránh conflict)
            Future.delayed(const Duration(seconds: 5), () {
              if (!isClosed) {
                print(
                    '🔄 PaymentCubit: Auto resetting to initial state after 5 seconds');
                emit(const PaymentState.initial());
              } else {
                print('⚠️ PaymentCubit: Skipping auto reset - cubit is closed');
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
    } catch (e, stackTrace) {
      print('❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌');
      print('❌ ERROR in PaymentCubit.listenForPaymentSuccess()!');
      print('   Error: $e');
      print('   Stack trace: $stackTrace');
      print('❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌');
      final errorMessage = _getErrorMessage(e);
      emit(PaymentState.paymentError(error: errorMessage));
    }
  }

  Future<void> cleanup() async {
    try {
      print('🧹 Cleaning up payment resources...');

      // Unregister listeners và disconnect socket
      await _paymentRepository.unregisterPaymentListener();

      // KHÔNG reset state ở đây - để user thấy success message
      // State sẽ được reset khi modal đóng hoặc sau 5 giây (auto reset)
      // Chỉ reset nếu đang ở trạng thái waiting hoặc error
      if (!isClosed) {
        final currentState = state;
        currentState.maybeWhen(
          waitingForPayment: (_) {
            print('🔄 Resetting from waitingForPayment to initial');
            emit(const PaymentState.initial());
          },
          paymentError: (_, __) {
            print('🔄 Resetting from paymentError to initial');
            emit(const PaymentState.initial());
          },
          orElse: () {
            print(
                '⚠️ Skipping state reset - current state: ${currentState.runtimeType}');
            print('   Keeping state so user can see success message');
          },
        );
      }

      print('✅ Cleanup completed');
    } catch (e) {
      print('⚠️ Error during cleanup: $e');
    }
  }

  void reset() {
    print('🔄 Resetting payment state');
    if (!isClosed) {
      emit(const PaymentState.initial());
    }
  }

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
