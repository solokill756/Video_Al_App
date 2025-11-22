import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';

import '../application/cubit/payment_cubit.dart';
import '../application/cubit/payment_state.dart';

/// 💳 **PaymentModal** - Modal displaying QR code and payment info
///
/// Features:
/// - QR code image for scanning with mobile banking
/// - Payment details: Bank, Account, Amount, Description
/// - Copy button for each field
/// - Real-time status update via socket
/// - Auto close when payment succeeds
///
/// Props:
/// - isOpen: Control modal visibility
/// - onClose: Callback when user closes modal
/// - planName: Plan name (BASIC, PREMIUM, etc)
/// - paymentInfo: Parsed payment details from QR link
///
/// State Flow:
/// - Display QR code + details
/// - Wait for payment (show loading)
/// - Success: Auto close + redirect
/// - Error: Show retry option
///
/// Socket Integration:
/// - Connect when modal opens
/// - Listen for paymentSuccess event
/// - Disconnect when modal closes

class PaymentModal extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final String planName;
  final String registrationLink;

  const PaymentModal({
    Key? key,
    required this.isOpen,
    required this.onClose,
    required this.planName,
    required this.registrationLink,
  }) : super(key: key);

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  /// 🎯 Parsed payment info từ QR link
  late PaymentInfo _paymentInfo;

  /// ✂️ Field được copy gần nhất (để highlight + show feedback)
  String? _copiedField;

  /// 🔌 PaymentCubit reference để cleanup socket
  PaymentCubit? _paymentCubit;

  /// ✅ Flag để track payment success (để hiển thị success UI ngay cả khi state bị reset)
  bool _hasPaymentSucceeded = false;

  @override
  void initState() {
    super.initState();
    // Parse payment info from URL
    print('📊 PaymentModal initState:');
    print('  - isOpen: ${widget.isOpen}');
    print('  - planName: ${widget.planName}');
    print('  - registrationLink: ${widget.registrationLink}');

    _paymentInfo = _parsePaymentLink(widget.registrationLink);

    print('  ✅ Parsed PaymentInfo:');
    print('    - qrUrl: ${_paymentInfo.qrUrl}');
    print('    - bankName: ${_paymentInfo.bankName}');
    print('    - accountNumber: ${_paymentInfo.accountNumber}');
    print('    - amount: ${_paymentInfo.amount}');
    print('    - description: ${_paymentInfo.description}');

    // Listen for socket events when modal opens
    if (widget.isOpen) {
      _setupSocketListener();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache PaymentCubit reference for cleanup
    _paymentCubit = context.read<PaymentCubit>();
  }

  @override
  void didUpdateWidget(PaymentModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOpen != widget.isOpen && widget.isOpen) {
      _setupSocketListener();
    }
    if (oldWidget.isOpen != widget.isOpen && !widget.isOpen) {
      _cleanupSocket();
    }
  }

  @override
  void dispose() {
    _cleanupSocket();
    super.dispose();
  }

  /// 🔌 **_setupSocketListener** - Setup socket listening
  ///
  /// When modal opens:
  /// 1. Socket connection is already setup by PaymentCubit.listenForPaymentSuccess()
  ///    called from parent widget when paymentLinkReceived state is emitted
  /// 2. This method is kept for reference but socket setup is handled externally
  ///
  /// Note: Socket connection happens in parent widget (pricing_page, etc)
  /// when PaymentState.paymentLinkReceived is received
  void _setupSocketListener() {
    print('🔌 PaymentModal: Socket listener setup handled by PaymentCubit');
    print(
        '   Socket connection is managed by PaymentCubit.listenForPaymentSuccess()');
  }

  /// 🔌 **_cleanupSocket** - Cleanup socket connection
  ///
  /// When modal closes:
  /// 1. Unregister socket listeners
  /// 2. Disconnect socket connection
  /// 3. Reset payment state
  /// 4. Release resources to prevent memory leaks
  ///
  /// Important: This must be called when:
  /// - User closes modal manually
  /// - Payment succeeds and modal auto-closes
  /// - Widget is disposed
  void _cleanupSocket() {
    try {
      print('🔌 PaymentModal: Cleaning up socket connection...');

      // Use cached PaymentCubit reference or get from context if available
      final paymentCubit =
          _paymentCubit ?? (mounted ? context.read<PaymentCubit>() : null);

      if (paymentCubit != null) {
        paymentCubit.cleanup();
        print('✅ PaymentModal: Socket cleanup completed');
      } else {
        print('⚠️ PaymentModal: PaymentCubit not available for cleanup');
      }
    } catch (e) {
      print('⚠️ PaymentModal: Error during socket cleanup: $e');
      // Don't rethrow - cleanup should be best effort
    }
  }

  /// 📝 **_parsePaymentLink** - Parse QR code URL to extract payment info
  ///
  /// Input: https://qr.sepay.vn/img?acc=888852690888&bank=VietinBank&amount=4000&des=SEVQR%20DHXXX1XXX5
  ///
  /// Output: PaymentInfo with fields:
  /// - accountNumber: "888852690888"
  /// - bankName: "VietinBank"
  /// - amount: "4000" → formatted "4,000 VND"
  /// - description: "SEVQR DHXXX1XXX5"
  /// - qrUrl: complete URL
  ///
  /// Algorithm:
  /// 1. Parse URL
  /// 2. Extract query parameters
  /// 3. Decode URL encoding
  /// 4. Format amount with thousand separators
  /// 5. Return PaymentInfo object
  PaymentInfo _parsePaymentLink(String url) {
    try {
      final uri = Uri.parse(url);
      final params = uri.queryParameters;

      final accountNumber = params['acc'] ?? '';
      final bankName = params['bank'] ?? '';
      final amountStr = params['amount'] ?? '';
      final description = params['des'] ?? '';

      // Format amount: "4000" → "4,000 VND"
      final amount = _formatAmount(amountStr);

      return PaymentInfo(
        accountNumber: accountNumber,
        bankName: bankName,
        amount: amount,
        description: description,
        qrUrl: url,
      );
    } catch (e) {
      print('❌ Error parsing payment link: $e');
      rethrow;
    }
  }

  /// 💰 **_formatAmount** - Format amount with thousand separators
  ///
  /// Input: "4000"
  /// Output: "4,000 VND"
  String _formatAmount(String amount) {
    try {
      final num = int.parse(amount);
      final formatted = num.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      return '$formatted VND';
    } catch (e) {
      return '$amount VND';
    }
  }

  /// 📋 **_copyToClipboard** - Copy field value and show feedback
  ///
  /// Steps:
  /// 1. Copy value to clipboard
  /// 2. Show "Copied!" toast
  /// 3. Highlight field so user knows it copied
  /// 4. Reset highlight after 2 seconds
  void _copyToClipboard(String value, String fieldName) {
    Clipboard.setData(ClipboardData(text: value));

    showToast(
      '✅ Copied $fieldName',
      position: ToastPosition.bottom,
      duration: const Duration(seconds: 2),
    );

    setState(() {
      _copiedField = fieldName;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copiedField = null;
        });
      }
    });
  }

  /// 🎨 **_buildPaymentInfoField** - Build single payment info field
  ///
  /// Display:
  /// ```
  /// ┌─ Label (Account Name)
  /// │  Value (0921000001)  [Copy Button]
  /// └─ (If copied: teal highlight)
  /// ```
  ///
  /// Features:
  /// - Label on top, value below
  /// - Copy button on right
  /// - Highlight when copied
  /// - Tap to select text
  /// - Long press to copy
  Widget _buildPaymentInfoField({
    required String label,
    required String value,
    required String fieldName,
    bool isImportant = false,
  }) {
    final isCopied = _copiedField == fieldName;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color:
              isImportant ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
          width: isImportant ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color:
            isCopied ? const Color(0xFF0D9488).withOpacity(0.08) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                // Value
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // Important warning
                if (isImportant)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '⚠️ Must enter exactly 100%',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF0D9488),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Copy button
          ElevatedButton.icon(
            onPressed: () => _copyToClipboard(value, fieldName),
            icon: Icon(
              isCopied ? Icons.check : Icons.copy,
              size: 16,
            ),
            label: Text(isCopied ? 'Copied' : 'Copy'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              backgroundColor:
                  isCopied ? const Color(0xFF0D9488) : const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              elevation: isCopied ? 2 : 1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentCubit, PaymentState>(
      listener: (context, state) {
        state.whenOrNull(
          // ✅ Payment success
          paymentSuccess: (message, subscription) {
            // Đánh dấu đã thành công
            setState(() {
              _hasPaymentSucceeded = true;
            });

            showToast(
              '🎉 $message',
              position: ToastPosition.bottom,
              duration: const Duration(seconds: 2),
            );

            // Auto close modal sau 2 giây và cleanup socket
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                // Cleanup socket before closing
                _cleanupSocket();
                widget.onClose();
              }
            });
          },
          // ❌ Payment error
          paymentError: (error, errorCode) {
            showToast(
              '❌ $error',
              position: ToastPosition.bottom,
              duration: const Duration(seconds: 3),
            );
          },
        );
      },
      child: AnimatedSlide(
        offset: widget.isOpen ? Offset.zero : const Offset(0, 1),
        duration: const Duration(milliseconds: 300),
        child: !widget.isOpen
            ? const SizedBox.shrink()
            : Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔘 Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment for ${widget.planName} plan',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Cleanup socket before closing
                              _cleanupSocket();
                              widget.onClose();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Color(0xFF64748B),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 📱 Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: BlocBuilder<PaymentCubit, PaymentState>(
                          builder: (context, state) {
                            print('🎨 PaymentModal BlocBuilder rebuild:');
                            print('  - State: ${state.runtimeType}');
                            print('  - State: $state');

                            // Nếu đã có payment success, luôn hiển thị success section
                            if (_hasPaymentSucceeded) {
                              return _buildSuccessSection();
                            }

                            return state.whenOrNull(
                                  // ⏳ Waiting for payment
                                  waitingForPayment: (planId) {
                                    print(
                                        '✅ Rendering waitingForPayment state');
                                    return Column(
                                      children: [
                                        // QR Code
                                        _buildQRCodeSection(),
                                        const SizedBox(height: 20),
                                        // Divider
                                        Divider(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                        const SizedBox(height: 16),
                                        // Payment info
                                        _buildPaymentInfoSection(),
                                        const SizedBox(height: 16),
                                        // Instructions
                                        _buildInstructionsSection(),
                                      ],
                                    );
                                  },
                                  // 💳 Payment link received (show same UI as waitingForPayment)
                                  paymentLinkReceived:
                                      (link, planId, planName) {
                                    print(
                                        '✅ Rendering paymentLinkReceived state');
                                    return Column(
                                      children: [
                                        // QR Code
                                        _buildQRCodeSection(),
                                        const SizedBox(height: 20),
                                        // Divider
                                        Divider(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                        const SizedBox(height: 16),
                                        // Payment info
                                        _buildPaymentInfoSection(),
                                        const SizedBox(height: 16),
                                        // Instructions
                                        _buildInstructionsSection(),
                                      ],
                                    );
                                  },
                                  // ✨ Payment success
                                  paymentSuccess: (message, subscription) =>
                                      _buildSuccessSection(),

                                  // ❌ Payment error
                                  paymentError: (error, errorCode) =>
                                      _buildErrorSection(error),
                                  // 🔄 Loading
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF0D9488),
                                      ),
                                    ),
                                  ),
                                  // Default - Nếu state là initial, hiển thị waitingForPayment UI
                                  // vì modal chỉ mở khi đã có payment link
                                  initial: () {
                                    print(
                                        '⚠️ PaymentModal: State is initial, showing waiting UI');
                                    return Column(
                                      children: [
                                        // QR Code
                                        _buildQRCodeSection(),
                                        const SizedBox(height: 20),
                                        // Divider
                                        Divider(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                        const SizedBox(height: 16),
                                        // Payment info
                                        _buildPaymentInfoSection(),
                                        const SizedBox(height: 16),
                                        // Instructions
                                        _buildInstructionsSection(),
                                      ],
                                    );
                                  },
                                ) ??
                                // Fallback: Hiển thị waiting UI nếu không match case nào
                                Column(
                                  children: [
                                    // QR Code
                                    _buildQRCodeSection(),
                                    const SizedBox(height: 20),
                                    // Divider
                                    Divider(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                    const SizedBox(height: 16),
                                    // Payment info
                                    _buildPaymentInfoSection(),
                                    const SizedBox(height: 16),
                                    // Instructions
                                    _buildInstructionsSection(),
                                  ],
                                );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// 🖼️ **_buildQRCodeSection** - Build QR code display
  ///
  /// Shows:
  /// - Large QR code image (200x200) generated from registrationLink
  /// - Instructions to scan
  /// - Manual entry option
  ///
  /// QR Code Generation:
  /// - Input: registrationLink URL (e.g., https://qr.sepay.vn/img?acc=...&bank=...&amount=...&des=...)
  /// - Process: Generate QR code from URL using qr_flutter package
  /// - Output: QR code image displayed in UI
  /// - User can scan with mobile banking app or enter details manually
  Widget _buildQRCodeSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFF8FAFC),
          ),
          child: Column(
            children: [
              // QR code
              Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: _buildQRCodeWidget(),
              ),
              const SizedBox(height: 12),
              Text(
                'Scan QR code with your banking app',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🎨 **_buildQRCodeWidget** - Display QR code image from SePayVN URL
  ///
  /// The registrationLink is already a URL to the QR image:
  /// https://qr.sepay.vn/img?acc=888852690888&bank=VietinBank&amount=2000&des=SEVQR...
  ///
  /// We just load it as an image using Image.network()
  Widget _buildQRCodeWidget() {
    print('🔍 DEBUG QR: qrUrl = ${_paymentInfo.qrUrl}');

    if (_paymentInfo.qrUrl.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_rounded,
              size: 40,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 8),
            const Text(
              'QR URL is empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return Image.network(
      _paymentInfo.qrUrl,
      width: 184,
      height: 184,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        print('⚠️ Error loading QR code image: $error');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 40,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 8),
              const Text(
                'Failed to load QR code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF0D9488),
            ),
          ),
        );
      },
    );
  }

  /// 💳 **_buildPaymentInfoSection** - Build payment details
  ///
  /// Shows:
  /// - Bank
  /// - Account number
  /// - Amount
  /// - Transfer description (highlighted - IMPORTANT)
  Widget _buildPaymentInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transfer Information',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        // Bank name
        _buildPaymentInfoField(
          label: 'Bank',
          value: _paymentInfo.bankName,
          fieldName: 'bank',
        ),
        // Account number
        _buildPaymentInfoField(
          label: 'Account Number',
          value: _paymentInfo.accountNumber,
          fieldName: 'account',
        ),
        // Amount
        _buildPaymentInfoField(
          label: 'Amount',
          value: _paymentInfo.amount,
          fieldName: 'amount',
        ),
        // Description (IMPORTANT - highlighted)
        _buildPaymentInfoField(
          label: 'Transfer Description',
          value: _paymentInfo.description,
          fieldName: 'description',
          isImportant: true,
        ),
      ],
    );
  }

  /// 📖 **_buildInstructionsSection** - Build step-by-step instructions
  ///
  /// Shows:
  /// 1. Open mobile banking app
  /// 2. Scan QR code OR enter details manually
  /// 3. Verify amount and content
  /// 4. Confirm transfer
  Widget _buildInstructionsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D9488).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF0D9488).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Instructions:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D9488),
            ),
          ),
          const SizedBox(height: 10),
          _buildInstructionStep(
            number: 1,
            text: 'Open your banking app on phone',
          ),
          _buildInstructionStep(
            number: 2,
            text: 'Scan QR code or enter transfer details above',
          ),
          _buildInstructionStep(
            number: 3,
            text: 'Verify amount and description (⚠️ MUST BE EXACT)',
          ),
          _buildInstructionStep(
            number: 4,
            text: 'Complete the transfer',
          ),
          const SizedBox(height: 10),
          const Text(
            'ℹ️ Payment will be activated within 1-2 minutes after confirmation',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF0D9488),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Step indicator
  Widget _buildInstructionStep({required int number, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0D9488),
            ),
            alignment: Alignment.center,
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ **_buildSuccessSection** - Build success message
  Widget _buildSuccessSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 80,
          color: Color(0xFF0D9488),
        ),
        const SizedBox(height: 16),
        const Text(
          '🎉 Payment successful!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D9488),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'The ${widget.planName} plan has been activated',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Redirecting...',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// ❌ **_buildErrorSection** - Build error message
  Widget _buildErrorSection(String error) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 80,
          color: Color(0xFFEF4444),
        ),
        const SizedBox(height: 16),
        const Text(
          'Payment Error',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFEF4444),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Cleanup socket before closing
                  _cleanupSocket();
                  widget.onClose();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5E7EB),
                  foregroundColor: const Color(0xFF1F2937),
                ),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Reset cubit state
                  context.read<PaymentCubit>().reset();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Try Again'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 📝 **PaymentInfo** - Helper class (normally from model)
///
/// Đây là local helper class để demo, in reality sẽ import từ model
class PaymentInfo {
  final String accountNumber;
  final String bankName;
  final String amount;
  final String description;
  final String qrUrl;

  PaymentInfo({
    required this.accountNumber,
    required this.bankName,
    required this.amount,
    required this.description,
    required this.qrUrl,
  });
}
