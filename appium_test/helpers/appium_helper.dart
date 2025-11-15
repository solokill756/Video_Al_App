// import 'package:appium_driver/appium_driver.dart';
// import '../config/appium_config.dart';

// /// Helper class for Appium test utilities
// class AppiumHelper {
//   late AppiumDriver driver;

//   /// Initialize Appium driver for Android
//   Future<void> initAndroidDriver(String appPath) async {
//     final capabilities = AppiumConfig.getAndroidCapabilities(appPath);
//     driver = await AppiumDriver.create(
//       Uri.parse(AppiumConfig.appiumServerUrl),
//       capabilities: capabilities,
//     );
//   }

//   /// Initialize Appium driver for iOS
//   Future<void> initIosDriver(String appPath) async {
//     final capabilities = AppiumConfig.getIosCapabilities(appPath);
//     driver = await AppiumDriver.create(
//       Uri.parse(AppiumConfig.appiumServerUrl),
//       capabilities: capabilities,
//     );
//   }

//   /// Close the driver
//   Future<void> closeDriver() async {
//     await driver.quit();
//   }

//   /// Wait for element by key
//   Future<WebElement> waitForElementByKey(
//     String key, {
//     Duration? timeout,
//   }) async {
//     timeout ??= AppiumConfig.defaultTimeout;
//     return await driver.findElement(
//       AppiumBy.key(key),
//       timeout: timeout,
//     );
//   }

//   /// Wait for element by text
//   Future<WebElement> waitForElementByText(
//     String text, {
//     Duration? timeout,
//   }) async {
//     timeout ??= AppiumConfig.defaultTimeout;
//     return await driver.findElement(
//       AppiumBy.text(text),
//       timeout: timeout,
//     );
//   }

//   /// Check if element exists
//   Future<bool> isElementPresent(String key) async {
//     try {
//       await driver.findElement(
//         AppiumBy.key(key),
//         timeout: AppiumConfig.shortTimeout,
//       );
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   /// Tap on element by key
//   Future<void> tapByKey(String key) async {
//     final element = await waitForElementByKey(key);
//     await element.click();
//   }

//   /// Tap on element by text
//   Future<void> tapByText(String text) async {
//     final element = await waitForElementByText(text);
//     await element.click();
//   }

//   /// Enter text in field
//   Future<void> enterText(String key, String text) async {
//     final element = await waitForElementByKey(key);
//     await element.clear();
//     await element.sendKeys(text);
//   }

//   /// Hide keyboard
//   Future<void> hideKeyboard() async {
//     try {
//       await driver.hideKeyboard();
//     } catch (e) {
//       // Keyboard might already be hidden
//       print('Could not hide keyboard: $e');
//     }
//   }

//   /// Take screenshot
//   Future<List<int>> takeScreenshot() async {
//     return await driver.screenshot();
//   }

//   /// Wait for specific duration
//   Future<void> wait(int milliseconds) async {
//     await Future.delayed(Duration(milliseconds: milliseconds));
//   }

//   /// Scroll to element
//   Future<void> scrollToElement(String key) async {
//     final element = await waitForElementByKey(key);
//     await driver.execute('mobile: scrollTo', [element]);
//   }

//   /// Swipe up
//   Future<void> swipeUp() async {
//     final size = await driver.getWindowSize();
//     final startX = size.width ~/ 2;
//     final startY = size.height * 0.8;
//     final endY = size.height * 0.2;

//     await driver.swipe(
//       startX: startX.toInt(),
//       startY: startY.toInt(),
//       endX: startX.toInt(),
//       endY: endY.toInt(),
//     );
//   }

//   /// Swipe down
//   Future<void> swipeDown() async {
//     final size = await driver.getWindowSize();
//     final startX = size.width ~/ 2;
//     final startY = size.height * 0.2;
//     final endY = size.height * 0.8;

//     await driver.swipe(
//       startX: startX.toInt(),
//       startY: startY.toInt(),
//       endX: startX.toInt(),
//       endY: endY.toInt(),
//     );
//   }

//   /// Get text from element
//   Future<String> getText(String key) async {
//     final element = await waitForElementByKey(key);
//     return await element.text;
//   }

//   /// Verify element is displayed
//   Future<bool> isElementDisplayed(String key) async {
//     try {
//       final element =
//           await waitForElementByKey(key, timeout: AppiumConfig.shortTimeout);
//       return await element.displayed;
//     } catch (e) {
//       return false;
//     }
//   }

//   /// Verify element is enabled
//   Future<bool> isElementEnabled(String key) async {
//     try {
//       final element = await waitForElementByKey(key);
//       return await element.enabled;
//     } catch (e) {
//       return false;
//     }
//   }
// }
