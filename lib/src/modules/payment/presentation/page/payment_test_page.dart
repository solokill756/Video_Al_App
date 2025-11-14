import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';

import '../application/cubit/payment_cubit.dart';
import '../application/cubit/payment_state.dart';
import '../components/payment_modal.dart';

/// 🧪 **PaymentTestPage** - Test page for Payment Module
///
/// Features:
/// - 3 service plans: FREE, BASIC, PREMIUM
/// - Subscribe button to trigger payment
/// - Payment modal to display QR code
/// - Test flow: Subscribe → QR → Payment Success
///
/// Usage:
/// - Navigate to this page
/// - Click "Upgrade" button
/// - Payment modal opens
/// - Test success/error flows

@RoutePage()
class PaymentTestPage extends StatefulWidget {
  const PaymentTestPage({Key? key}) : super(key: key);

  @override
  State<PaymentTestPage> createState() => _PaymentTestPageState();
}

class _PaymentTestPageState extends State<PaymentTestPage> {
  // 🔧 Config
  bool _isPaymentModalOpen = false;
  String _selectedPlanName = '';
  String _paymentLink = '';

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentCubit, PaymentState>(
      listener: (context, state) {
        state.whenOrNull(
          // ✅ Nhận được payment link → Open modal
          paymentLinkReceived: (link, planId, planName) {
            print('✅ Payment link received: $link');
            setState(() {
              _paymentLink = link;
              _selectedPlanName = planName;
              _isPaymentModalOpen = true;
            });

            // Setup socket listener
            context.read<PaymentCubit>().listenForPaymentSuccess(
                  planId: int.parse(planId),
                );
          },

          // 🎉 Payment success
          paymentSuccess: (message, subscription) {
            print('🎉 Payment success: $message');

            showToast(
              '✅ $message',
              position: ToastPosition.bottom,
              duration: const Duration(seconds: 3),
            );

            // Auto close modal sau 3 giây
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                _onPaymentModalClose();
              }
            });
          },

          // ❌ Payment error
          paymentError: (error, code) {
            print('❌ Payment error: $error');

            showToast(
              '❌ $error',
              position: ToastPosition.bottom,
              duration: const Duration(seconds: 4),
            );
          },
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Select a Service Plan'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => context.router.back(),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF64748B),
                size: 18,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            // Main content
            _buildMainContent(),

            // Payment Modal (overlay)
            if (_isPaymentModalOpen)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: PaymentModal(
                  isOpen: _isPaymentModalOpen,
                  onClose: _onPaymentModalClose,
                  planName: _selectedPlanName,
                  registrationLink: _paymentLink,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 📱 Build main content
  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            '💳 Choose Your Plan',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Test payment flow by clicking the "Upgrade" button',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),

          // Plan 1: FREE
          _buildPlanCard(
            name: 'FREE',
            price: '0 VND',
            features: [
              '10 videos/month',
              'Basic editing',
              'Watermark',
            ],
            color: const Color(0xFF9CA3AF),
            planId: null, // No subscription for FREE
          ),
          const SizedBox(height: 16),

          // Plan 2: BASIC
          _buildPlanCard(
            name: 'BASIC',
            price: '99,000 VND',
            features: [
              '100 videos/month',
              'Advanced editing',
              'No watermark',
              'HD export',
            ],
            color: const Color(0xFF0D9488),
            planId: 1,
          ),
          const SizedBox(height: 16),

          // Plan 3: PREMIUM
          _buildPlanCard(
            name: 'PREMIUM',
            price: '299,000 VND',
            features: [
              'Unlimited videos',
              'All features',
              'Priority support',
              '4K export',
              'Custom branding',
            ],
            color: const Color(0xFF8B5CF6),
            planId: 2,
          ),
          const SizedBox(height: 32),

          // Test buttons section
          _buildTestSection(),
        ],
      ),
    );
  }

  /// 🎴 Build single plan card
  Widget _buildPlanCard({
    required String name,
    required String price,
    required List<String> features,
    required Color color,
    required int? planId,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Features
          ...features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: color, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),

          // Subscribe button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: planId != null
                  ? () => _onSubscribePressed(
                        planId: planId,
                        planName: name,
                      )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    planId != null ? color : const Color(0xFFE5E7EB),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                planId != null ? 'Upgrade' : 'Current Plan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color:
                      planId != null ? Colors.white : const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🧪 Test section với mock buttons
  Widget _buildTestSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7).withOpacity(0.3),
        border: Border.all(
          color: const Color(0xFFFCD34D),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.science, color: Color(0xFFD97706), size: 20),
              SizedBox(width: 8),
              Text(
                '🧪 TEST CONTROLS',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Mock payment responses (for testing when backend is not ready)',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),

          // Mock Success button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _mockPaymentSuccess,
              icon: const Icon(Icons.check_circle, size: 18),
              label: const Text('Mock Payment Success'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Mock Error button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _mockPaymentError,
              icon: const Icon(Icons.error, size: 18),
              label: const Text('Mock Payment Error'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Reset button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<PaymentCubit>().reset();
                setState(() {
                  _isPaymentModalOpen = false;
                });
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reset State'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD97706),
                side: const BorderSide(
                  color: Color(0xFFD97706),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🛒 On Subscribe button pressed
  void _onSubscribePressed({
    required int planId,
    required String planName,
  }) {
    print('✅ Subscribe pressed: $planName (ID: $planId)');

    // Show loading
    showToast(
      '⏳ Getting payment information...',
      position: ToastPosition.bottom,
    );

    // Call PaymentCubit
    context.read<PaymentCubit>().getPaymentLink(
          planId: planId,
          planName: planName,
        );
  }

  /// 🚫 On Payment Modal Close
  void _onPaymentModalClose() {
    print('🚫 Payment modal closed');

    // Cleanup
    context.read<PaymentCubit>().cleanup();

    // Close modal
    setState(() {
      _isPaymentModalOpen = false;
      _paymentLink = '';
    });
  }

  /// 🧪 Mock payment success (for testing)
  ///
  /// Note: Cannot mock from UI, must test with real backend
  /// or create tests in PaymentCubit test file
  void _mockPaymentSuccess() {
    print('🧪 Mock not available - Test with real backend API');
    showToast(
      'ℹ️ To test, click Subscribe and backend will return QR code',
      position: ToastPosition.bottom,
    );
  }

  /// 🧪 Mock payment error (for testing)
  void _mockPaymentError() {
    print('🧪 Mock not available - Test with real backend API');
    showToast(
      'ℹ️ Error will appear if backend cannot connect',
      position: ToastPosition.bottom,
    );
  }

  @override
  void dispose() {
    // Cleanup khi page dispose
    if (_isPaymentModalOpen) {
      context.read<PaymentCubit>().cleanup();
    }
    super.dispose();
  }
}
