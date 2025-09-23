import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/dialogs/app_dialogs.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../app/app_router.dart';
import '../application/cubit/auth_cubit.dart';
import '../application/cubit/auth_state.dart';

@RoutePage()
class RegisterDetailPage extends StatelessWidget {
  final String email;

  const RegisterDetailPage({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return RegisterDetailView(email: email);
  }
}

class RegisterDetailView extends StatefulWidget {
  final String email;

  const RegisterDetailView({
    super.key,
    required this.email,
  });

  @override
  State<RegisterDetailView> createState() => _RegisterDetailViewState();
}

class _RegisterDetailViewState extends State<RegisterDetailView> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _otpFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();

    // Thiết lập status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpFocus.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    // Tắt bàn phím ảo
    FocusScope.of(context).unfocus();

    final otp = _otpController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (otp.isEmpty) {
      AppDialogs.showSnackBar(
        message: 'Please enter OTP code',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (otp.length != 6) {
      AppDialogs.showSnackBar(
        message: 'OTP code must be 6 digits',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (name.isEmpty) {
      AppDialogs.showSnackBar(
        message: 'Please enter your full name',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (phone.isEmpty) {
      AppDialogs.showSnackBar(
        message: 'Please enter phone number',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (phone.length != 10) {
      AppDialogs.showSnackBar(
        message: 'Invalid phone number',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (password.isEmpty) {
      AppDialogs.showSnackBar(
        message: 'Please enter password',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (password != confirmPassword) {
      AppDialogs.showSnackBar(
        message: 'Password confirmation does not match',
        backgroundColor: Colors.red,
      );
      return;
    }

    context.read<AuthCubit>().register(
          email: widget.email,
          password: password,
          name: name,
          phoneNumber: phone,
          otpCode: otp,
          confirmPassword: confirmPassword,
        );
  }

  void _handleResendOTP() {
    FocusScope.of(context).unfocus();

    context.read<AuthCubit>().sendOtp(email: widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.router.pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF374151),
          ),
        ),
        title: const Text(
          'Complete Registration',
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          state.maybeWhen(
            registerSuccess: (registerResponse) {
              AppDialogs.showSnackBar(
                message: registerResponse.message,
                backgroundColor: Colors.green,
              );
              context.router.replaceAll([const LoginRoute()]);
            },
            error: (message) {
              AppDialogs.showSnackBar(
                message: message,
                backgroundColor: Colors.red,
              );
            },
            orElse: () {},
          );
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Main content card
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title
                          const Text(
                            'Complete Registration',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          // Subtitle
                          const Text(
                            'Điền thông tin để hoàn tất tài khoản',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          // Email field
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.email_outlined,
                                  color: Color(0xFF9CA3AF),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.email,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // OTP field
                          const Text(
                            'OTP Code (6 digits)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildOTPField(),
                                  ),
                                  const SizedBox(width: 12),
                                  TextButton(
                                    onPressed: _handleResendOTP,
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(0xFFF3F4F6),
                                      foregroundColor: const Color(0xFF374151),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: state.maybeWhen(
                                      loading: () =>
                                          const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Color(0xFF374151),
                                        ),
                                      ),
                                      orElse: () => const Text(
                                        'Gửi lại',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // Name field
                          const Text(
                            'Full Name',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            hintText: 'Enter your full name',
                            prefixIcon: Icons.person_outlined,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_phoneFocus);
                            },
                          ),

                          const SizedBox(height: 20),

                          // Phone field
                          const Text(
                            'Phone Number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _phoneController,
                            focusNode: _phoneFocus,
                            hintText: 'Enter phone number',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_passwordFocus);
                            },
                          ),

                          const SizedBox(height: 20),

                          // Password field
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            hintText: 'Enter password',
                            prefixIcon: Icons.lock_outlined,
                            isPassword: true,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_confirmPasswordFocus);
                            },
                            onToggleObscure: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          // Confirm Password field
                          const Text(
                            'Confirm Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocus,
                            hintText: 'Re-enter password',
                            prefixIcon: Icons.lock_outlined,
                            isPassword: true,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleRegister(),
                            onToggleObscure: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),

                          const SizedBox(height: 32),

                          // Register button
                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              final isLoading = state.maybeWhen(
                                loadingRegister: () => true,
                                orElse: () => false,
                              );

                              return LoadingButton(
                                isLoading: isLoading,
                                onPressed: _handleRegister,
                                text: 'Complete Registration',
                                loadingText: 'Processing...',
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // Login link
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    context.router.push(const LoginRoute());
                                  },
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF0D9488),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOTPField() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _otpController,
        focusNode: _otpFocus,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 6,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) {
          FocusScope.of(context).requestFocus(_nameFocus);
        },
        style: const TextStyle(
          fontSize: 20,
          color: Color(0xFF1F2937),
          fontWeight: FontWeight.bold,
          letterSpacing: 8,
        ),
        decoration: InputDecoration(
          hintText: '000000',
          hintStyle: const TextStyle(
            color: Color(0xFFA1A1AA),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF0D9488),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Function(String)? onSubmitted,
    VoidCallback? onToggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF1F2937),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFFA1A1AA),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              prefixIcon,
              color: const Color(0xFF9CA3AF),
              size: 20,
            ),
          ),
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: onToggleObscure,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF9CA3AF),
                      size: 20,
                    ),
                  ),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF0D9488),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
