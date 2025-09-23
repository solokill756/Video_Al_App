import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/dialogs/app_dialogs.dart';
import '../../../app/app_router.dart';
import '../application/cubit/auth_cubit.dart';
import '../application/cubit/auth_state.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginView();
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    // Set up status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      AppDialogs.showSnackBar(
        message: 'Please enter your email',
        backgroundColor: Colors.red,
      );
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      AppDialogs.showSnackBar(
        message: 'Please enter a valid email',
        backgroundColor: Colors.red,
      );
      return;
    }
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      AppDialogs.showSnackBar(
        message: 'Please enter your password',
        backgroundColor: Colors.red,
      );
      return;
    }

    await context.read<AuthCubit>().login(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            state.maybeWhen(
              initial: () {},
              loading: () {},
              loginSuccess: (loginResponse) {
                AppDialogs.showSnackBar(
                  message: 'Login successful! Welcome back',
                  backgroundColor: Colors.green,
                );
                // Navigate to home screen
                context.router.push(const VideoSearchHomeRoute());
              },
              error: (message) {
                AppDialogs.showSnackBar(
                  message: message,
                  backgroundColor: Colors.red,
                );
              },
              validationError: (apiError) {
                // Show validation errors
                final errors = apiError.validationErrors;
                if (errors.isNotEmpty) {
                  // Display the first or summary of errors
                  String errorMessage =
                      errors.map((e) => '${e.field}: ${e.message}').join('\n');
                  AppDialogs.showSnackBar(
                    message: errorMessage,
                    backgroundColor: Colors.red,
                  );
                }
              },
              orElse: () {},
            );
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),

                    // Logo and main title
                    Center(
                      child: Column(
                        children: [
                          // VideoAI Logo
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D9488),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Text VideoAI
                          const Text(
                            'VideoAI',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Subtitle
                          const Text(
                            'Login to your account',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Login Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFD1FAE5),
                          width: 1,
                        ),
                      ),
                      child: BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Login title
                              const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Enter your information to access the system',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
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
                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  String? emailError;
                                  state.maybeWhen(
                                    validationError: (apiError) {
                                      emailError =
                                          apiError.getValidationError('email');
                                    },
                                    orElse: () {},
                                  );

                                  return _buildTextField(
                                    controller: _emailController,
                                    focusNode: _emailFocus,
                                    hintText: 'your@email.com',
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    errorText: emailError,
                                    onSubmitted: (_) {
                                      FocusScope.of(context)
                                          .requestFocus(_passwordFocus);
                                    },
                                  );
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
                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  String? passwordError;
                                  state.maybeWhen(
                                    validationError: (apiError) {
                                      passwordError = apiError
                                          .getValidationError('password');
                                    },
                                    orElse: () {},
                                  );

                                  return _buildTextField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocus,
                                    hintText: '••••••••',
                                    prefixIcon: Icons.lock_outlined,
                                    isPassword: true,
                                    textInputAction: TextInputAction.done,
                                    errorText: passwordError,
                                    onSubmitted: (_) => _handleLogin(),
                                  );
                                },
                              ),

                              const SizedBox(height: 16),

                              // Forgot password
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    // Handle forgot password
                                  },
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF0D9488),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Login button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: state.maybeWhen(
                                    loading: () => null,
                                    orElse: () => _handleLogin,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D9488),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    disabledBackgroundColor:
                                        const Color(0xFF0D9488)
                                            .withOpacity(0.6),
                                  ),
                                  child: state.maybeWhen(
                                    loading: () => const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                    orElse: () => const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Register link
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.router.push(const RegisterRoute());
                            },
                            child: const Text(
                              'Sign up now',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Function(String)? onSubmitted,
    String? errorText,
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
        obscureText: isPassword ? _obscurePassword : false,
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
              color: errorText != null
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF9CA3AF),
              size: 20,
            ),
          ),
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF9CA3AF),
                      size: 20,
                    ),
                  ),
                )
              : null,
          errorText: errorText,
          errorStyle: const TextStyle(
            color: Color(0xFFDC2626),
            fontSize: 12,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: errorText != null
                  ? const Color(0xFFDC2626)
                  : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: errorText != null
                  ? const Color(0xFFDC2626)
                  : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: errorText != null
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF0D9488),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFDC2626),
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFDC2626),
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
