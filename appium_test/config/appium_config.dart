/// Appium Configuration for Flutter E2E Testing
/// This file contains all configuration settings for Appium tests

class AppiumConfig {
  // Appium Server Configuration
  static const String appiumServerUrl = 'http://127.0.0.1:4723/wd/hub';

  // Android Configuration
  static const String androidPlatformName = 'Android';
  static const String androidPlatformVersion =
      '13.0'; // Adjust based on your device
  static const String androidDeviceName = 'Android Emulator';
  static const String androidAutomationName = 'Flutter';

  // iOS Configuration
  static const String iosPlatformName = 'iOS';
  static const String iosPlatformVersion =
      '16.0'; // Adjust based on your device
  static const String iosDeviceName = 'iPhone 14';
  static const String iosAutomationName = 'Flutter';

  // App Configuration
  static const String appPackage =
      'com.example.dmvgenie'; // Replace with your package name
  static const String appActivity = '.MainActivity';

  // Test Configuration
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);
  static const Duration longTimeout = Duration(seconds: 60);

  // Test Data
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'Test@123456';
  static const String testName = 'Test User';
  static const String testPhone = '0123456789';
  static const String testOtp = '123456';

  // Get Android Capabilities
  static Map<String, dynamic> getAndroidCapabilities(String appPath) {
    return {
      'platformName': androidPlatformName,
      'platformVersion': androidPlatformVersion,
      'deviceName': androidDeviceName,
      'automationName': androidAutomationName,
      'app': appPath,
      'appPackage': appPackage,
      'appActivity': appActivity,
      'noReset': false,
      'fullReset': true,
      'newCommandTimeout': 300,
    };
  }

  // Get iOS Capabilities
  static Map<String, dynamic> getIosCapabilities(String appPath) {
    return {
      'platformName': iosPlatformName,
      'platformVersion': iosPlatformVersion,
      'deviceName': iosDeviceName,
      'automationName': iosAutomationName,
      'app': appPath,
      'noReset': false,
      'fullReset': true,
      'newCommandTimeout': 300,
    };
  }
}
