import 'package:dmvgenie/src/common/dialogs/app_dialogs.dart';
import 'package:dmvgenie/src/common/widgets/hide_keyboard_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../application/cubit/settings_cubit.dart';
import 'password_input_field.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({
    super.key,
  });

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late FocusNode _currentPasswordFocus;
  late FocusNode _newPasswordFocus;
  late FocusNode _confirmPasswordFocus;

  bool _isLoading = false;
  bool _passwordStrengthValid = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _currentPasswordFocus = FocusNode();
    _newPasswordFocus = FocusNode();
    _confirmPasswordFocus = FocusNode();

    _newPasswordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _newPasswordController.text;
    final isValid = password.length >= 8 &&
        _confirmPasswordController.text == password &&
        _currentPasswordController.text.isNotEmpty;

    setState(() {
      _passwordStrengthValid = isValid;
    });

    if (_passwordStrengthValid) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Current password is required';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'New password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (value == _currentPasswordController.text) {
      return 'New password must be different from current';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _handleChangePassword() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<SettingsCubit>().changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
            confirmPassword: _confirmPasswordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) =>
          current is ChangingPassword ||
          current is ChangePasswordSuccess ||
          current is ChangePasswordFailure,
      listener: (context, state) {
        state.maybeWhen(
          changingPassword: () {
            setState(() {
              _isLoading = true;
            });
          },
          changePasswordSuccess: (message) {
            setState(() {
              _isLoading = false;
            });
            Navigator.of(context).pop();
            AppDialogs.showSnackBar(
              message: message,
              backgroundColor: Colors.green,
            );
          },
          changePasswordFailure: (message) {
            setState(() {
              _isLoading = false;
            });
            AppDialogs.showSnackBar(
              message: message,
              backgroundColor: Colors.red,
            );
          },
          orElse: () {},
        );
      },
      child: HideKeyboardOnTap(
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
                          Icons.lock,
                          color: Color(0xFF0D9488),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Change Password',
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Info message
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
                                  'Use a strong password with at least 8 characters',
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
                        const SizedBox(height: 24),
                        // Current Password Field
                        PasswordInputField(
                          label: 'Current Password',
                          hint: 'Enter your current password',
                          controller: _currentPasswordController,
                          focusNode: _currentPasswordFocus,
                          textInputAction: TextInputAction.next,
                          validator: _validateCurrentPassword,
                          enabled: !_isLoading,
                          onEditingComplete: () {
                            _currentPasswordFocus.unfocus();
                            FocusScope.of(context)
                                .requestFocus(_newPasswordFocus);
                          },
                        ),
                        const SizedBox(height: 20),
                        // New Password Field
                        PasswordInputField(
                          label: 'New Password',
                          hint: 'Enter your new password',
                          controller: _newPasswordController,
                          focusNode: _newPasswordFocus,
                          textInputAction: TextInputAction.next,
                          validator: _validateNewPassword,
                          enabled: !_isLoading,
                          onEditingComplete: () {
                            _newPasswordFocus.unfocus();
                            FocusScope.of(context)
                                .requestFocus(_confirmPasswordFocus);
                          },
                        ),
                        const SizedBox(height: 20),
                        // Confirm Password Field
                        PasswordInputField(
                          label: 'Confirm Password',
                          hint: 'Confirm your new password',
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocus,
                          textInputAction: TextInputAction.done,
                          validator: _validateConfirmPassword,
                          enabled: !_isLoading,
                          onEditingComplete: () {
                            _confirmPasswordFocus.unfocus();
                          },
                        ),
                        const SizedBox(height: 20),
                        // Password Strength Indicator
                        _buildPasswordStrengthIndicator(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
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
                onPressed: _isLoading
                    ? null
                    : (_passwordStrengthValid ? _handleChangePassword : null),
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
                child: _isLoading
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
                        'Update Password',
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
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _newPasswordController.text;

    int strength = 0;
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool isLongEnough = password.length >= 8;

    if (isLongEnough) strength++;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialChar) strength++;

    Color strengthColor = Colors.grey[400] ?? Colors.grey;
    String strengthText = 'Weak';

    if (strength <= 2) {
      strengthColor = Colors.red;
      strengthText = 'Weak';
    } else if (strength <= 3) {
      strengthColor = Colors.orange;
      strengthText = 'Fair';
    } else if (strength <= 4) {
      strengthColor = Colors.blue;
      strengthText = 'Good';
    } else {
      strengthColor = Colors.green;
      strengthText = 'Strong';
    }

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: strength / 5,
              minHeight: 6,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          strengthText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: strengthColor,
          ),
        ),
      ],
    );
  }
}
