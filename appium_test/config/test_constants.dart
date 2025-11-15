/// Test Constants
/// Contains all constants used in E2E tests

class TestConstants {
  // Widget Keys - These should match the keys in your Flutter app
  // Login Page
  static const String loginEmailField = 'login_email_field';
  static const String loginPasswordField = 'login_password_field';
  static const String loginButton = 'login_button';
  static const String loginRegisterLink = 'login_register_link';
  static const String loginForgotPasswordLink = 'login_forgot_password_link';

  // Register Page
  static const String registerEmailField = 'register_email_field';
  static const String registerContinueButton = 'register_continue_button';
  static const String registerLoginLink = 'register_login_link';

  // Register Detail Page
  static const String registerOtpField = 'register_otp_field';
  static const String registerResendButton = 'register_resend_button';
  static const String registerNameField = 'register_name_field';
  static const String registerPhoneField = 'register_phone_field';
  static const String registerPasswordField = 'register_password_field';
  static const String registerConfirmPasswordField =
      'register_confirm_password_field';
  static const String registerSubmitButton = 'register_submit_button';

  // Common
  static const String backButton = 'back_button';
  static const String loadingIndicator = 'loading_indicator';

  // Text Labels
  static const String loginPageTitle = 'Login';
  static const String registerPageTitle = 'Create Account';
  static const String registerDetailPageTitle = 'Complete Registration';

  // Success/Error Messages
  static const String loginSuccessMessage = 'Login successful';
  static const String registerSuccessMessage = 'Registration successful';
  static const String invalidEmailMessage = 'Please enter a valid email';
  static const String emptyPasswordMessage = 'Please enter your password';
  static const String passwordMismatchMessage =
      'Password confirmation does not match';

  // Wait Times (in milliseconds)
  static const int shortWait = 2000;
  static const int mediumWait = 5000;
  static const int longWait = 10000;

  // Retry Configuration
  static const int maxRetries = 3;
  static const int retryDelay = 1000;
}

/// Test Data
class TestData {
  // Valid Test User
  static const String validEmail = 'validuser@test.com';
  static const String validPassword = 'ValidPass123!';
  static const String validName = 'Valid Test User';
  static const String validPhone = '0987654321';
  static const String validOtp = '123456';

  // Invalid Test Data
  static const String invalidEmail = 'invalid-email';
  static const String shortPassword = '123';
  static const String emptyString = '';

  // Edge Cases
  static const String longEmail =
      'verylongemailaddressverylongemailaddressverylongemailaddress@test.com';
  static const String specialCharsPassword = '!@#\$%^&*()_+';
  static const String unicodeText = 'Tiếng Việt có dấu';
}
