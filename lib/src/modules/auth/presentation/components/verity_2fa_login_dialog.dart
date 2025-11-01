import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/dialogs/app_dialogs.dart';
import '../../../../core/data/local/storage.dart';
import '../../../app/app_router.dart';
import '../application/cubit/auth_cubit.dart';
import '../application/cubit/auth_state.dart';

class Verify2FALoginDialog extends StatefulWidget {
  const Verify2FALoginDialog({
    super.key,
  });

  @override
  State<Verify2FALoginDialog> createState() => _Verify2FALoginDialogState();
}

class _Verify2FALoginDialogState extends State<Verify2FALoginDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  late FocusNode _focusNode;
  late AnimationController _animationController;
  int _remainingAttempts = 3;
  bool _showResendOption = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _codeController.addListener(_handleCodeChange);
    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _codeController.removeListener(_handleCodeChange);
    _codeController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleCodeChange() {
    setState(() {});
    if (_codeController.text.length == 6) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onVerifyPressed() {
    if (_codeController.text.length == 6) {
      context.read<AuthCubit>().verify2FA(
            otpCode: _codeController.text,
          );
    }
  }

  // void _onResendCode() {
  //   context.read<AuthCubit>().resend2FACode(email: widget.email);
  //   AppDialogs.showSnackBar(
  //     message: 'Verification code has been resent',
  //     backgroundColor: Colors.blue,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (prev, current) =>
          current is TwoFactorAuthVerifiedFailure ||
          current is TwoFactorAuthVerifiedSuccess ||
          current is TwoFactorAuthVerifying,
      listener: (context, state) {
        state.maybeWhen(
          twoFactorAuthVerifiedSuccess: (String message) {
            AppDialogs.showSnackBar(
              message: message,
              backgroundColor: Colors.green,
            );
            Storage.setIsEnable2FA(false);
            context.router.replaceAll([const VideoSearchHomeRoute()]);
          },
          twoFactorAuthVerifiedFailure: (String message) {
            setState(() {
              _remainingAttempts--;
              if (_remainingAttempts <= 0) {
                _showResendOption = true;
              }
            });
            AppDialogs.showSnackBar(
              message: message,
              backgroundColor: Colors.redAccent,
            );
            _codeController.clear();
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        final bool isVerifying = state is TwoFactorAuthVerifying;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final isCodeValid = _codeController.text.length == 6;

        return WillPopScope(
          onWillPop: () async => !isVerifying,
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            contentPadding: const EdgeInsets.all(0),
            backgroundColor: Colors.white,
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey[800]
                          : const Color(0xFF0D9488).withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0D9488).withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFF0D9488),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Two-Factor Authentication',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter 6-digit code',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? Colors.grey[200]
                                : Colors.grey[800],
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Code from your authenticator app',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // OTP Input
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _codeController,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              textAlign: TextAlign.center,
                              enabled: !isVerifying,
                              style: const TextStyle(
                                fontSize: 28,
                                letterSpacing: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: '000000',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  letterSpacing: 12,
                                ),
                                filled: true,
                                fillColor: isDarkMode
                                    ? Colors.grey[900]
                                    : Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300] ?? Colors.grey,
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300] ?? Colors.grey,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF0D9488),
                                    width: 2,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300] ?? Colors.grey,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isCodeValid
                                      ? '✓ Valid code'
                                      : '${_codeController.text.length}/6 digits',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isCodeValid
                                        ? Colors.green
                                        : Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_remainingAttempts > 0)
                                  Text(
                                    'Attempts left: $_remainingAttempts',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _remainingAttempts <= 1
                                          ? Colors.red
                                          : Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Error message if attempts exceeded
                        if (_showResendOption)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              border: const Border(
                                left: BorderSide(
                                  color: Colors.orange,
                                  width: 4,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_outlined,
                                      color: Colors.orange,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'Too many incorrect attempts',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // GestureDetector(
                                //   onTap: _showResendOption && !isVerifying
                                //       ? _onResendCode
                                //       : null,
                                //   child: Text(
                                //     'Resend verification code',
                                //     style: TextStyle(
                                //       fontSize: 12,
                                //       color: const Color(0xFF0D9488),
                                //       fontWeight: FontWeight.w600,
                                //       decoration: TextDecoration.underline,
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        // Info box
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            border: const Border(
                              left: BorderSide(
                                color: Colors.blue,
                                width: 4,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.blue,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Code expires in 30 seconds',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[700],
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    isVerifying ? null : () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ),
              ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.05)
                    .animate(_animationController),
                child: ElevatedButton(
                  onPressed: isVerifying
                      ? null
                      : (isCodeValid ? _onVerifyPressed : null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    disabledBackgroundColor: Colors.grey[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ],
            actionsPadding: const EdgeInsets.all(16),
          ),
        );
      },
    );
  }
}
