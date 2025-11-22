import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';
import 'package:dmvgenie/src/modules/upload/data/model/plan_model.dart';
import 'package:dmvgenie/src/modules/plan/presentation/application/cubit/plan_cubit.dart';
import 'package:dmvgenie/src/modules/plan/presentation/application/cubit/plan_state.dart'
    as plan_state;

import '../application/cubit/payment_cubit.dart';
import '../application/cubit/payment_state.dart';
import '../components/payment_modal.dart';

/// 💳 **PricingPage** - Hiển thị danh sách gói dịch vụ
///
/// Features:
/// - Danh sách 3 gói dịch vụ: FREE, BASIC, PREMIUM
/// - Hiển thị thông tin chi tiết mỗi gói (giá, features)
/// - "Choose Plan" button cho BASIC, PREMIUM
/// - FREE plan được mặc định
/// - Click Subscribe → Trigger payment flow
///
/// User Journey:
/// 1. User xem danh sách gói
/// 2. Click "Choose Plan" button
/// 3. PaymentModal mở, hiển thị QR code
/// 4. User quét QR hoặc chuyển khoản thủ công
/// 5. Backend emit paymentSuccess → Modal đóng
/// 6. Redirect tới video management
///
/// Integration:
/// - PaymentCubit: Lấy QR code
/// - PaymentModal: Hiển thị thanh toán
/// - PlanCubit: Lấy danh sách gói (optional, có thể hardcode)

@RoutePage()
class PricingPage extends StatefulWidget {
  const PricingPage({Key? key}) : super(key: key);

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  // 🔧 State
  late bool _isPaymentModalOpen;
  late String _selectedPlanName;
  late String _paymentLink;

  @override
  void initState() {
    super.initState();
    _isPaymentModalOpen = false;
    _selectedPlanName = '';
    _paymentLink = '';

    // Load plans từ backend
    _loadPlans();
  }

  /// 📥 **_loadPlans** - Load plans từ PlanCubit
  ///
  /// Fetch danh sách gói từ backend qua PlanCubit
  /// Transform Plan model thành PricingPlanData
  void _loadPlans() {
    // Load plans từ PlanCubit
    context.read<PlanCubit>().loadPlans(pageIndex: 1, pageSize: 100);
  }

  /// 🔄 **_convertPlansToUi** - Convert Plan models to PricingPlanData
  ///
  /// Transform backend Plan model thành UI PricingPlanData
  /// với color, description, isImportant flags
  List<PricingPlanData> _convertPlansToUi(List<Plan> plans) {
    // Sort by price: FREE first, then ascending
    final sortedPlans = List<Plan>.from(plans)
      ..sort((a, b) {
        if (a.price == 0) return -1; // FREE first
        if (b.price == 0) return 1;
        return a.price.compareTo(b.price);
      });

    return sortedPlans.map((plan) {
      // Determine color based on plan type
      Color color;
      String description;
      bool isPremium;

      if (plan.price == 0) {
        color = const Color(0xFF9CA3AF);
        description = 'Perfect for getting started';
        isPremium = false;
      } else if (plan.name.toUpperCase().contains('BASIC')) {
        color = const Color(0xFF0D9488);
        description = 'Great for creators';
        isPremium = true;
      } else {
        color = const Color(0xFF8B5CF6);
        description = 'For professional creators';
        isPremium = true;
      }

      // Extract features from plan.features map
      final List<String> features = [];
      plan.features.forEach((key, value) {
        if (value == true || (value is String && value.isNotEmpty)) {
          // Format key as readable feature
          final feature = key
              .replaceAll('_', ' ')
              .split(' ')
              .map((word) => word[0].toUpperCase() + word.substring(1))
              .join(' ');
          features.add(feature);
        }
      });

      return PricingPlanData(
        id: plan.price == 0 ? null : plan.id, // FREE has no ID for subscription
        name: plan.name,
        price: '${plan.price.toStringAsFixed(0)} VND', // "99000 VND" or "0 VND"
        description: description,
        features: features.isNotEmpty
            ? features
            : [
                'Feature 1',
                'Feature 2',
                'Feature 3',
              ], // Fallback if no features
        color: color,
        isPremium: isPremium,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentCubit, PaymentState>(
      listener: _handlePaymentState,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Pricing Plans'),
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

  /// 🎯 **_handlePaymentState** - Handle payment state changes
  ///
  /// Listening từ PaymentCubit để biết khi nào:
  /// - Payment link được nhận → Open modal
  /// - Payment success → Close modal, redirect
  /// - Payment error → Show error toast
  void _handlePaymentState(BuildContext context, PaymentState state) {
    state.whenOrNull(
      // ✅ Nhận được payment link → Open modal
      paymentLinkReceived: (link, planId, planName) {
        print('✅ Payment link received: $link');
        print('🔍 PricingPage state change:');
        print('  - planId: $planId');
        print('  - planName: $planName');
        print('  - link: $link');

        setState(() {
          _paymentLink = link;
          _selectedPlanName = planName;
          _isPaymentModalOpen = true;
        });

        print('  ✅ Modal opened: _isPaymentModalOpen = $_isPaymentModalOpen');

        // Setup socket listener để chờ payment success
        print('🔌🔌🔌 PricingPage: Calling listenForPaymentSuccess()...');
        print('   Plan ID: $planId (parsed: ${int.parse(planId)})');
        try {
          context.read<PaymentCubit>().listenForPaymentSuccess(
                planId: int.parse(planId),
              );
          print(
              '✅✅✅ PricingPage: listenForPaymentSuccess() called successfully');
        } catch (e, stackTrace) {
          print('❌❌❌ PricingPage: Error calling listenForPaymentSuccess()!');
          print('   Error: $e');
          print('   Stack trace: $stackTrace');
        }
      },

      // 🎉 Payment success
      paymentSuccess: (message, subscription) {
        print('🎉 Payment success: $message');

        showToast(
          '✅ $message',
          position: ToastPosition.bottom,
          duration: const Duration(seconds: 2),
        );

        // Auto close modal sau 2 giây
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _onPaymentModalClose();
            // Optionally redirect tới video management
            // context.router.replace(const VideoManagementRoute());
          }
        });
      },

      // ❌ Payment error
      paymentError: (error, code) {
        print('❌ Payment error: $error');

        showToast(
          '❌ $error',
          position: ToastPosition.bottom,
          duration: const Duration(seconds: 3),
        );
      },
    );
  }

  /// 📱 **_buildMainContent** - Main content with pricing cards
  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          _buildHeaderSection(),
          const SizedBox(height: 32),

          // Pricing cards - Fetch from PlanCubit
          BlocBuilder<PlanCubit, plan_state.PlanState>(
            builder: (context, state) {
              return state.maybeWhen(
                // Loading state
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF0D9488),
                    ),
                  ),
                ),
                // Plans loaded state
                plansLoaded: (plans) {
                  // Convert backend Plan models to UI PricingPlanData
                  final pricingPlans = _convertPlansToUi(plans);

                  return Column(
                    children: [
                      ...pricingPlans.map((plan) => Column(
                            children: [
                              _buildPricingCard(plan),
                              const SizedBox(height: 16),
                            ],
                          )),
                    ],
                  );
                },
                // Error state
                error: (message) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '❌ Lỗi tải danh sách gói dịch vụ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                // Default/Initial state
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),

          const SizedBox(height: 20),

          // FAQ section (optional)
          _buildFaqSection(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// 📝 **_buildHeaderSection** - Header with title and description
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💳 Choose Your Plan',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the perfect plan for your video creation needs',
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// 🎴 **_buildPricingCard** - Single pricing plan card
  ///
  /// Display:
  /// - Plan name and price
  /// - Description
  /// - Features list with checkmarks
  /// - Choose Plan button (or Current Plan badge for FREE)
  /// - Badge for most popular (optional for PREMIUM)
  Widget _buildPricingCard(PricingPlanData plan) {
    final isCurrent = plan.name == 'FREE'; // Assume user always has FREE

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(
          color: plan.color,
          width: plan.isPremium ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        color: plan.color.withOpacity(0.04),
        boxShadow: [
          if (plan.isPremium)
            BoxShadow(
              color: plan.color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          else
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
          // Header: name + price + badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: plan.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              if (plan.isPremium && plan.name == 'PREMIUM')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: plan.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '⭐ Popular',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Price
          Text(
            plan.price,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: plan.color,
            ),
          ),
          if (plan.isPremium)
            Text(
              '/month',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 20),

          // Divider
          Divider(
            color: plan.color.withOpacity(0.2),
            thickness: 1,
          ),
          const SizedBox(height: 20),

          // Features
          ...plan.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: plan.color,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1F2937),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrent ? null : () => _onChoosePlanPressed(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isCurrent ? const Color(0xFFE5E7EB) : plan.color,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isCurrent ? 0 : 2,
              ),
              child: Text(
                isCurrent ? '✓ Current Plan' : 'Choose Plan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isCurrent ? const Color(0xFF9CA3AF) : Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ❓ **_buildFaqSection** - FAQ section
  Widget _buildFaqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        _buildFaqItem(
          question: 'Can I upgrade or downgrade my plan anytime?',
          answer:
              'Yes, you can change your plan at any time. Changes will take effect in the next billing cycle.',
        ),
        _buildFaqItem(
          question: 'Is there a free trial?',
          answer: 'Yes! Start with our FREE plan with 10 videos per month.',
        ),
        _buildFaqItem(
          question: 'What payment methods do you accept?',
          answer: 'We accept all major Vietnamese banks via QR code transfer.',
        ),
      ],
    );
  }

  /// 📋 **_buildFaqItem** - Single FAQ item
  Widget _buildFaqItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// 🛒 **_onChoosePlanPressed** - Handle Choose Plan button press
  ///
  /// Flow:
  /// 1. Validate user is logged in
  /// 2. Check if plan is FREE (no payment needed)
  /// 3. If paid plan: Call PaymentCubit.getPaymentLink()
  /// 4. PaymentCubit sẽ emit PaymentLinkReceived state
  /// 5. _handlePaymentState sẽ open modal
  void _onChoosePlanPressed(PricingPlanData plan) {
    if (plan.id == null) {
      // FREE plan - no payment needed
      showToast(
        '✅ FREE plan selected',
        position: ToastPosition.bottom,
      );
      return;
    }

    print('✅ Choose plan pressed: ${plan.name} (ID: ${plan.id})');

    // Show loading
    showToast(
      '⏳ Preparing payment...',
      position: ToastPosition.bottom,
    );

    // Trigger payment flow
    context.read<PaymentCubit>().getPaymentLink(
          planId: plan.id!,
          planName: plan.name,
        );
  }

  /// 🚫 **_onPaymentModalClose** - Handle modal close
  ///
  /// Cleanup:
  /// 1. Close modal
  /// 2. Reset payment link
  /// 3. Cleanup socket (via PaymentCubit)
  void _onPaymentModalClose() {
    print('🚫 Payment modal closed');

    // Cleanup socket
    context.read<PaymentCubit>().cleanup();

    // Reset UI state
    setState(() {
      _isPaymentModalOpen = false;
      _paymentLink = '';
      _selectedPlanName = '';
    });
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

/// 📦 **PricingPlanData** - Model cho pricing plan
///
/// Local data class để hold pricing plan information
class PricingPlanData {
  final int? id; // null for FREE plan
  final String name;
  final String price;
  final String description;
  final List<String> features;
  final Color color;
  final bool isPremium;

  PricingPlanData({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.features,
    required this.color,
    required this.isPremium,
  });
}
