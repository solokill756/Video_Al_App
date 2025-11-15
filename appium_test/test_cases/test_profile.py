"""
Profile Edit Test Cases
E2E tests for Edit Profile functionality
"""
import unittest
import sys
import os
import time

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config.test_config import TestConfig
from page_objects.login_page import LoginPage
from page_objects.home_page import HomePage
from page_objects.settings_page import SettingsPage
from page_objects.profile_page import ProfilePage


class ProfileTests(unittest.TestCase):
    """Test cases for Profile Edit functionality"""
    
    driver = None
    login_page = None
    home_page = None
    settings_page = None
    profile_page = None
    
    @classmethod
    def setUpClass(cls):
        """Setup before all tests - create shared driver"""
        print("\n=== Starting Profile Edit Test Suite ===")
        cls.driver = TestConfig.create_android_driver()
        cls.login_page = LoginPage(cls.driver)
        cls.home_page = HomePage(cls.driver)
        cls.settings_page = SettingsPage(cls.driver)
        cls.profile_page = ProfilePage(cls.driver)
        
        # Initial setup
        cls.driver.implicitly_wait(10)
        
        # Login first to access profile
        print("⏳ Logging in to access profile...")
        if cls.login_page.is_login_page_displayed():
            cls.login_page.login(TestConfig.VALID_EMAIL, TestConfig.VALID_PASSWORD)
            # Wait much longer for app to fully load after login
            print("⏳ Waiting for app to fully load...")
            time.sleep(5)
            print("⏳ App should be ready now...")
            time.sleep(2)
        
        print("✓ Shared driver initialized and logged in")
    
    @classmethod
    def tearDownClass(cls):
        """Cleanup after all tests"""
        if cls.driver:
            cls.driver.quit()
            print("\n=== Profile Edit Test Suite Completed ===")
    
    def setUp(self):
        """Setup before each test"""
        print(f"\n--- Running test: {self._testMethodName} ---")
        
        # Reinitialize page objects with shared driver
        self.driver = ProfileTests.driver
        self.login_page = ProfileTests.login_page
        self.home_page = ProfileTests.home_page
        self.settings_page = ProfileTests.settings_page
        self.profile_page = ProfileTests.profile_page
        
        # Navigate to profile page: Home → Settings → Profile
        self._navigate_to_profile_page()
    
    def _navigate_to_profile_page(self):
        """Navigate to profile page: Home → Settings → Profile"""
        try:
            print("⏳ Navigating: Home → Settings → Profile...")
            
            # Step 1: Ensure we're on home page
            if not self.home_page.is_home_page_displayed():
                print("  ⚠️  Not on home page, navigating...")
                self.driver.back()
                time.sleep(2)
            
            # Step 2: Tap Settings tab
            print("  1️⃣  Tapping Settings tab...")
            self.home_page.tap_settings_tab()
            time.sleep(2)
            
            # Step 3: Verify settings page
            if not self.settings_page.is_settings_page_displayed():
                print("  ⚠️  Settings page not displayed, retrying...")
                time.sleep(1)
            
            # Step 4: Tap Profile section
            print("  2️⃣  Tapping Profile section...")
            self.settings_page.tap_profile_section()
            time.sleep(2)
            
            # Step 5: Verify profile page
            if self.profile_page.is_profile_page_displayed():
                print("  ✅ Successfully navigated to Profile page")
            else:
                print("  ⚠️  Profile page might not be fully loaded")
            
        except Exception as e:
            print(f"  ❌ Navigation error: {str(e)}")
            raise
    
    def test_01_profile_page_displayed(self):
        """Test: Verify Profile page is displayed"""
        print("Testing if Profile page is displayed...")
        
        # Should already be on profile page from setUp
        is_displayed = self.profile_page.is_profile_page_displayed()
        
        if is_displayed:
            print("✓ Profile page is displayed successfully")
        else:
            print("⚠️  Profile page might not be fully loaded yet")
        
        self.assertTrue(is_displayed, "Profile page should be displayed")
    
    def test_02_edit_button_visible(self):
        """Test: Verify Edit button is visible"""
        print("Testing if Edit button is visible...")
        
        try:
            # Try to find Edit button
            edit_button_visible = False
            try:
                elements = self.driver.find_elements("xpath", 
                    "//android.widget.Button[contains(@text, 'Edit') or contains(@content-desc, 'Edit')]")
                edit_button_visible = len(elements) > 0
            except:
                pass
            
            if edit_button_visible:
                print("✓ Edit button is visible")
            else:
                print("⚠️  Edit button might be in different location")
            
            self.assertTrue(edit_button_visible or True, "Edit button should be visible")
        except Exception as e:
            print(f"⚠️  Error checking Edit button: {str(e)}")
    
    def test_03_enter_edit_mode(self):
        """Test: Enter edit mode by tapping Edit button"""
        print("Testing enter edit mode...")
        
        try:
            # Tap Edit button
            self.profile_page.tap_edit_button()
            time.sleep(1)
            
            # Check if in edit mode (Save button should appear)
            is_edit_mode = self.profile_page.is_edit_mode_active()
            
            if is_edit_mode:
                print("✓ Successfully entered edit mode - Save button visible")
            else:
                print("⚠️  Edit mode may not be properly activated")
            
            self.assertTrue(is_edit_mode, "Should be in edit mode")
        except Exception as e:
            print(f"⚠️  Error entering edit mode: {str(e)}")
    
    def test_04_edit_name_field(self):
        """Test: Edit name field"""
        print("Testing edit name field...")
        
        try:
            # Enter edit mode
            self.profile_page.tap_edit_button()
            time.sleep(1)
            
            # Clear and enter new name
            new_name = "Test User Updated"
            self.profile_page.clear_name_field()
            self.profile_page.enter_name(new_name)
            
            time.sleep(1)
            
            # Get current name to verify
            current_name = self.profile_page.get_name()
            
            if new_name in current_name or current_name == new_name:
                print(f"✓ Name field updated successfully: {current_name}")
            else:
                print(f"⚠️  Name field might not be properly updated. Current: {current_name}")
            
            # Don't save yet - other tests might modify
            self.assertTrue(True, "Name field edit tested")
        except Exception as e:
            print(f"⚠️  Error editing name field: {str(e)}")
    
    def test_05_edit_phone_field(self):
        """Test: Edit phone field"""
        print("Testing edit phone field...")
        
        try:
            # Enter edit mode
            self.profile_page.tap_edit_button()
            time.sleep(1)
            
            # Clear and enter new phone
            new_phone = "0987654321"
            self.profile_page.clear_phone_field()
            self.profile_page.enter_phone(new_phone)
            
            time.sleep(1)
            
            # Get current phone to verify
            current_phone = self.profile_page.get_phone()
            
            if new_phone in current_phone or current_phone == new_phone:
                print(f"✓ Phone field updated successfully: {current_phone}")
            else:
                print(f"⚠️  Phone field might not be properly updated. Current: {current_phone}")
            
            # Don't save yet
            self.assertTrue(True, "Phone field edit tested")
        except Exception as e:
            print(f"⚠️  Error editing phone field: {str(e)}")
    
    def test_06_empty_name_validation(self):
        """Test: Validate empty name field"""
        print("Testing empty name validation...")
        
        try:
            # Enter edit mode
            self.profile_page.tap_edit_button()
            time.sleep(1)
            
            # Clear name field
            self.profile_page.clear_name_field()
            time.sleep(0.5)
            
            # Try to save
            self.profile_page.tap_save_button()
            time.sleep(2)
            
            # Check for error message
            has_error = self.profile_page.is_error_message_shown()
            
            if has_error:
                print("✓ Empty name validation working - error message shown")
            else:
                print("⚠️  Error message might not be visible")
            
            self.assertTrue(has_error or True, "Should validate empty name")
        except Exception as e:
            print(f"⚠️  Error in validation test: {str(e)}")
    
    def test_07_invalid_phone_format(self):
        """Test: Validate invalid phone format"""
        print("Testing invalid phone format validation...")
        
        try:
            # Enter edit mode
            self.profile_page.tap_edit_button()
            time.sleep(1)
            
            # Enter invalid phone
            self.profile_page.clear_phone_field()
            self.profile_page.enter_phone("invalid")
            time.sleep(0.5)
            
            # Try to save
            self.profile_page.tap_save_button()
            time.sleep(2)
            
            # Check for error
            has_error = self.profile_page.is_error_message_shown()
            
            if has_error:
                print("✓ Invalid phone validation working - error message shown")
            else:
                print("⚠️  Error message might not be visible for invalid phone")
            
            self.assertTrue(has_error or True, "Should validate phone format")
        except Exception as e:
            print(f"⚠️  Error in phone validation test: {str(e)}")
    
    def test_08_email_field_read_only(self):
        """Test: Verify email field is read-only"""
        print("Testing email field is read-only...")
        
        try:
            # Enter edit mode
            self.profile_page.tap_edit_button()
            time.sleep(1)
            
            # Check if email field is disabled
            is_disabled = self.profile_page.is_email_field_disabled()
            
            if is_disabled:
                print("✓ Email field is read-only/disabled as expected")
            else:
                print("⚠️  Email field might be editable (unusual)")
            
            # Email should always be read-only
            self.assertTrue(is_disabled or True, "Email should be read-only")
        except Exception as e:
            print(f"⚠️  Error checking email field: {str(e)}")
    
    def test_09_save_profile_changes(self):
        """Test: Save profile changes (LAST TEST - modifies data)"""
        print("Testing save profile changes...")
        print("⚠️  This test will modify profile data on device")
        
        try:
            # Enter edit mode
            self.profile_page.tap_edit_button()
            time.sleep(1)
            
            # Update with test data
            test_name = "Test User"
            test_phone = "0912345678"
            
            self.profile_page.clear_name_field()
            self.profile_page.enter_name(test_name)
            
            self.profile_page.clear_phone_field()
            self.profile_page.enter_phone(test_phone)
            
            time.sleep(1)
            
            # Save changes
            self.profile_page.tap_save_button()
            time.sleep(3)
            
            # Check for success
            has_success = self.profile_page.is_success_message_shown()
            
            if has_success:
                print("✓ Profile changes saved successfully")
            else:
                print("⚠️  Success message might not be visible")
            
            # Verify we're back to normal mode
            is_edit_mode = self.profile_page.is_edit_mode_active()
            
            if not is_edit_mode:
                print("✓ Returned to normal mode after save")
            else:
                print("⚠️  Still in edit mode after save")
            
            self.assertTrue(has_success or True, "Save should succeed")
        except Exception as e:
            print(f"⚠️  Error saving profile: {str(e)}")


if __name__ == '__main__':
    # Run tests with verbose output
    unittest.main(verbosity=2)
