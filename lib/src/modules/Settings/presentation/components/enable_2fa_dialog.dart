import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../common/dialogs/app_dialogs.dart';
import '../application/cubit/settings_cubit.dart';

enum Step2FASetup { scanQr, enterCode }

class Enable2FADialog extends StatefulWidget {
  const Enable2FADialog({super.key});

  @override
  State<Enable2FADialog> createState() => _Enable2FADialogState();
}

class _Enable2FADialogState extends State<Enable2FADialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    context.read<SettingsCubit>().getLinkFor2FA();
    _codeController.addListener(_handleCodeChange);
  }

  @override
  void dispose() {
    _codeController.removeListener(_handleCodeChange);
    _codeController.dispose();
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
      context.read<SettingsCubit>().enable2FA(otpCode: _codeController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listenWhen: (prev, current) =>
          current is Settings2FALoadingLink ||
          current is Settings2FAError ||
          current is Settings2FASuccess,
      listener: (context, state) {
        state.maybeWhen(
          twoFASuccess: (message) {
            Navigator.of(context, rootNavigator: true).pop();
            AppDialogs.showSnackBar(
              message: message,
              backgroundColor: Colors.green,
            );
          },
          twoFAError: (message, previousUri) {
            AppDialogs.showSnackBar(
              message: message,
              backgroundColor: Colors.redAccent,
            );
          },
          orElse: () {},
        );
      },
      buildWhen: (prev, current) =>
          current is Settings2FALoadingLink ||
          current is Settings2FALoadedLink ||
          current is Settings2FAEnabling ||
          current is Settings2FAError,
      builder: (context, state) {
        final bool isEnabling = state is Settings2FAEnabling;
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
                          Icons.verified_user,
                          color: Color(0xFF0D9488),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Enable 2-Factor Authentication',
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
                      // Step 1: QR Code
                      _buildStepNumber('1'),
                      const SizedBox(height: 8),
                      Text(
                        'Scan this QR code with your authenticator app',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              isDarkMode ? Colors.grey[200] : Colors.grey[800],
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '(e.g., Google Authenticator, Microsoft Authenticator)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // QR Code display
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[300] ?? Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: _buildQrCode(state),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Divider
                      Container(
                        height: 1,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 24),
                      // Step 2: Enter code
                      _buildStepNumber('2'),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the 6-digit code to verify',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              isDarkMode ? Colors.grey[200] : Colors.grey[800],
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Code input field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            enabled: !isEnabling,
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
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isCodeValid
                                ? '✓ Valid code - Ready to verify'
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
                      const SizedBox(height: 16),
                      // Info box
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
                                'Save your recovery codes in a safe place',
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
              onPressed: isEnabling ? null : () => Navigator.of(context).pop(),
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
                onPressed:
                    isEnabling ? null : (isCodeValid ? _onVerifyPressed : null),
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
                child: isEnabling
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
                        'Verify & Enable',
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

  Widget _buildStepNumber(String step) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFF0D9488),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          step,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildQrCode(SettingsState state) {
    return state.maybeWhen(
      twoFALoadingLink: () => const SizedBox(
        width: 200,
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      twoFALoadedLink: (qrCodeUri) => QrImageView(
        data: qrCodeUri,
        version: QrVersions.auto,
        size: 200.0,
        backgroundColor: Colors.white,
      ),
      // Giữ mã QR hiển thị ngay cả khi đang xác minh
      twoFAEnabling: (previousUri) => QrImageView(
        data: previousUri ?? '',
        version: QrVersions.auto,
        size: 200.0,
        backgroundColor: Colors.white,
      ),
      twoFAError: (message, previousUri) => QrImageView(
        data: previousUri ?? '',
        version: QrVersions.auto,
        size: 200.0,
        backgroundColor: Colors.white,
      ),
      orElse: () => const SizedBox(
        width: 200,
        height: 200,
        child: Center(
          child: Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
        ),
      ),
    );
  }
}
