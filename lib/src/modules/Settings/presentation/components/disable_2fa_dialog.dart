import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/dialogs/app_dialogs.dart';
import '../application/cubit/settings_cubit.dart';

enum InputFocusState { unfocused, focused, filled }

class Disable2FADialog extends StatefulWidget {
  const Disable2FADialog({super.key});

  @override
  State<Disable2FADialog> createState() => _Disable2FADialogState();
}

class _Disable2FADialogState extends State<Disable2FADialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  late FocusNode _focusNode;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _codeController.addListener(_handleCodeChange);
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

  void _onDisablePressed() {
    if (_codeController.text.length == 6) {
      context.read<SettingsCubit>().disable2FA(otpCode: _codeController.text);
    } else {
      AppDialogs.showSnackBar(
        message: 'Please enter a valid 6-digit code.',
        backgroundColor: Colors.redAccent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listenWhen: (prev, current) =>
          current is Settings2FASuccess || current is Settings2FAError,
      listener: (context, state) {
        state.maybeWhen(
          twoFASuccess: (message) {
            // Đóng dialog và hiển thị thông báo
            Navigator.of(context, rootNavigator: true)
                .pop(); // Trả về true để báo thành công
            AppDialogs.showSnackBar(
              message: message,
              backgroundColor: Colors.green,
            );
          },
          twoFAError: (message, previousUri) {
            // Hiển thị lỗi
            AppDialogs.showSnackBar(
              message: message,
              backgroundColor: Colors.redAccent,
            );
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        final bool isDisabling = state is Settings2FADisabling;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final isCodeValid = _codeController.text.length == 6;

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          contentPadding: const EdgeInsets.all(0),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
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
                          Icons.security,
                          color: Color(0xFF0D9488),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Disable 2-Factor Authentication',
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
                      // Warning message with better styling
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withOpacity(0.1),
                          border: const Border(
                            left: BorderSide(
                              color: Color(0xFF0D9488),
                              width: 4,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: const Text(
                          'To enhance security, please enter the 6-digit code from your authenticator app to confirm disabling.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // OTP Input
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Authentication Code',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return TextField(
                                controller: _codeController,
                                focusNode: _focusNode,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                textAlign: TextAlign.center,
                                enabled: !isDisabling,
                                style: const TextStyle(
                                  fontSize: 24,
                                  letterSpacing: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: '000000',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    letterSpacing: 8,
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
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isCodeValid
                                ? '✓ Valid code'
                                : '${_codeController.text.length}/6 digits',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isCodeValid ? Colors.green : Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isDisabling ? null : () => Navigator.of(context).pop(),
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
                onPressed: isDisabling
                    ? null
                    : (isCodeValid ? _onDisablePressed : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  disabledBackgroundColor: Colors.grey[400],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isDisabling
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
                        'Disable 2FA',
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
        );
      },
    );
  }
}
