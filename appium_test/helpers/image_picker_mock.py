"""
Solution: Mock Image Picker via Method Channel

This Python script demonstrates how to mock ImagePicker 
using Flutter's platform channel mechanism via adb.

The app needs to support:
- A method channel "com.fau.dmvgenie/avatar"
- A method "pickImage" that can be mocked

But EASIER: Just test via actual file system
"""

import subprocess
import time
import os
import tempfile


class MockImagePickerHelper:
    """
    Helper to mock image picker by:
    1. Pushing file to known location
    2. Using adb to trigger file selection
    """
    
    @staticmethod
    def push_test_image_to_device(device_path: str = "/sdcard/test_avatar.png") -> bool:
        """Push test image to device"""
        print(f"\n📸 Pushing test image to {device_path}...")
        
        # Create minimal PNG
        png_data = (
            b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR'
            b'\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00'
            b'\xc8\xe1\xf7\x91\x00\x00\x00\x0cIDAT\x08\xd7c\xf8\xcf\xc0'
            b'\x00\x00\x03\x01\x00\x01\xe5?\xa6\x10\x00\x00\x00\x00IEND'
            b'\xaeB`\x82'
        )
        
        with tempfile.NamedTemporaryFile(suffix='.png', delete=False) as f:
            f.write(png_data)
            temp_path = f.name
        
        try:
            result = subprocess.run(
                ["adb", "push", temp_path, device_path],
                capture_output=True,
                timeout=10,
                text=True
            )
            os.unlink(temp_path)
            
            if result.returncode == 0:
                print(f"   ✅ Image pushed successfully")
                return True
            else:
                print(f"   ❌ Push failed: {result.stderr}")
                return False
        except Exception as e:
            print(f"   ❌ Error: {e}")
            os.unlink(temp_path)
            return False
    
    @staticmethod
    def trigger_file_manager(file_path: str):
        """Trigger file manager to open specific file"""
        print(f"\n📂 Triggering file manager for {file_path}...")
        
        cmd = [
            "adb", "shell", "am", "start", "-a", "android.intent.action.VIEW",
            "-d", f"file://{file_path}",
            "-t", "image/png"
        ]
        
        try:
            result = subprocess.run(cmd, capture_output=True, timeout=10)
            if result.returncode == 0:
                print(f"   ✅ File manager triggered")
                return True
            else:
                print(f"   ⚠️  Return code: {result.returncode}")
                return False
        except Exception as e:
            print(f"   ❌ Error: {e}")
            return False
    
    @staticmethod
    def tap_screen_center(driver, delay: float = 1.0):
        """Simulate tapping screen center (for confirming file selection)"""
        print(f"\n👆 Tapping screen center...")
        try:
            # Get screen size
            size = driver.get_window_size()
            center_x = size['width'] // 2
            center_y = size['height'] // 2
            
            driver.tap([(center_x, center_y)], duration=1)
            print(f"   ✅ Tapped at ({center_x}, {center_y})")
            
            if delay > 0:
                time.sleep(delay)
            return True
        except Exception as e:
            print(f"   ❌ Error: {e}")
            return False
    
    @staticmethod
    def scan_media_on_device(file_path: str):
        """Broadcast media scanner to index file"""
        print(f"\n📡 Scanning media for {file_path}...")
        
        cmd = [
            "adb", "shell", "am", "broadcast", "-a",
            "android.intent.action.MEDIA_SCANNER_SCAN_FILE",
            "-d", f"file://{file_path}"
        ]
        
        try:
            result = subprocess.run(cmd, capture_output=True, timeout=10)
            if result.returncode == 0:
                print(f"   ✅ Media scanned")
                return True
            else:
                print(f"   ⚠️  Scan returned: {result.returncode}")
                return False
        except Exception as e:
            print(f"   ❌ Error: {e}")
            return False
    
    @staticmethod
    def check_app_upload_state(driver) -> dict:
        """
        Check if app is in upload state
        Returns: {
            'uploading': bool,
            'success': bool,
            'error': bool,
            'message': str
        }
        """
        print(f"\n🔍 Checking app state...")
        
        state = {
            'uploading': False,
            'success': False,
            'error': False,
            'message': ''
        }
        
        try:
            # Check for "Uploading avatar..."
            loading = driver.find_elements("xpath", 
                "//*[contains(@text, 'Uploading')]")
            if loading:
                state['uploading'] = True
                print(f"   ✅ Upload in progress")
            
            # Check for success messages
            success_indicators = driver.find_elements("xpath", 
                "//*[contains(@text, 'Success') or contains(@text, 'success') or contains(@text, 'uploaded')]")
            if success_indicators:
                state['success'] = True
                state['message'] = success_indicators[0].get_attribute('text')
                print(f"   ✅ Success: {state['message']}")
            
            # Check for error messages
            error_indicators = driver.find_elements("xpath", 
                "//*[contains(@text, 'Error') or contains(@text, 'error') or contains(@text, 'failed')]")
            if error_indicators:
                state['error'] = True
                state['message'] = error_indicators[0].get_attribute('text')
                print(f"   ❌ Error: {state['message']}")
            
        except Exception as e:
            print(f"   ⚠️  Check failed: {e}")
        
        return state
    
    @staticmethod
    def setup_testing_environment():
        """
        Print instructions for setting up app testing mode
        """
        print("\n" + "="*80)
        print("SETUP: Add Testing Mode to Flutter App")
        print("="*80)
        print("""
        To enable mock image picker, add to profile_page.dart:

        ```dart
        import 'dart:io' show Platform;
        import 'package:flutter/foundation.dart';

        // In _ProfileViewState:
        bool get _isTestingMode {
          // Check for environment variable or platform channel
          return kDebugMode; // or read from env
        }

        Future<void> _pickImageFromGallery() async {
          try {
            await _checkPermissions();

            // IN TESTING MODE: Use mock file instead of real picker
            if (_isTestingMode && Platform.isAndroid) {
              // Check for test file
              final testFile = File('/sdcard/test_avatar.png');
              if (testFile.existsSync()) {
                setState(() {
                  _selectedImage = testFile;
                });
                await _uploadImage();
                return;
              }
            }

            // Normal flow: Use real image picker
            final XFile? image = await _imagePicker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 80,
              maxWidth: 1000,
              maxHeight: 1000,
            );

            if (image != null) {
              setState(() {
                _selectedImage = File(image.path);
              });
              await _uploadImage();
            }
          } catch (e) {
            AppDialogs.showSnackBar(
              message: 'Error: ${e.toString()}',
              backgroundColor: Colors.red,
            );
          }
        }
        ```

        Then rebuild app and tests will work!
        """)


# Usage example
if __name__ == '__main__':
    print("\n" + "="*80)
    print("IMAGE PICKER MOCK HELPER")
    print("="*80)
    
    # Show setup instructions
    MockImagePickerHelper.setup_testing_environment()
    
    print("\n" + "="*80)
    print("USAGE IN TESTS")
    print("="*80)
    print("""
    from helpers.image_picker_mock import MockImagePickerHelper
    
    class MyTest(unittest.TestCase):
        def test_avatar_upload(self):
            # Push test image
            MockImagePickerHelper.push_test_image_to_device()
            
            # Scan media
            MockImagePickerHelper.scan_media_on_device("/sdcard/test_avatar.png")
            
            # Tap camera button (via appium)
            scrollview = self.driver.find_elements("xpath", "//android.widget.ScrollView")
            if scrollview:
                clickables = self.driver.find_elements("xpath",
                    "//android.widget.ScrollView//android.view.View[@clickable='true']")
                if clickables:
                    clickables[0].click()
            
            # Tap gallery
            gallery = self.driver.find_elements("xpath",
                "//*[contains(@content-desc, 'Choose from Gallery')]")
            if gallery:
                gallery[0].click()
            
            # Wait for app to load test image
            time.sleep(3)
            
            # Check upload state
            state = MockImagePickerHelper.check_app_upload_state(self.driver)
            self.assertTrue(state['uploading'] or state['success'])
    """)
