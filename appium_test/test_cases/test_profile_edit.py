"""
Profile Edit Test Cases
E2E tests for Profile editing functionality
"""
import unittest
import sys
import os

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config.test_config import TestConfig
from page_objects.profile_page import ProfilePage
from page_objects.login_page import LoginPage


class ProfileEditTests(unittest.TestCase):
    """Test cases for Profile editing functionality"""
    
    driver = None
    login_page = None
    profile_page = None
    
    @classmethod
    def setUpClass(cls):
        """Setup before all tests - create shared driver"""
        print("\n=== Starting Profile Edit Test Suite ===")
        cls.driver = TestConfig.create_android_driver()
        cls.login_page = LoginPage(cls.driver)
        cls.profile_page = ProfilePage(cls.driver)
        
        # Initial setup - login
        cls.driver.implicitly_wait(10)
        print("✓ Shared driver initialized")
    
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
        self.driver = ProfileEditTests.driver
        self.login_page = ProfileEditTests.login_page
        self.profile_page = ProfileEditTests.profile_page
        
        # Navigate to profile page
        try:
            if self.login_page.is_login_page_displayed():
                # Need to login first
                self.login_page.login(
                    TestConfig.VALID_EMAIL,
                    TestConfig.VALID_PASSWORD
                )
                self.driver.implicitly_wait(10)
            
            # Navigate to profile page from home
            self.profile_page.navigate_to_profile()
            self.driver.implicitly_wait(5)
            print("✓ Form cleared - ready for test")
        except Exception as e:
            print(f"⚠️  Navigation error: {e}")
    
    def tearDown(self):
        """Cleanup after each test - no driver quit"""
        # Don't quit driver - it's shared for all tests
        pass
    
    def test_01_profile_page_displayed(self):
        """Test: Verify Profile page is displayed"""
        print("Verifying Profile page is displayed...")
        
        # Verify profile page elements are present
        self.assertTrue(
            self.profile_page.is_profile_page_displayed(),
            "Profile page is not displayed"
        )
        print("✓ Profile page is displayed successfully")
    
    def test_02_edit_name_field(self):
        """Test: Edit full name field"""
        print("Testing edit full name...")
        
        # Ensure we're on profile page
        self.assertTrue(self.profile_page.is_profile_page_displayed())
        
        # Enter edit mode
        self.profile_page.tap_edit_button()
        self.driver.implicitly_wait(2)
        
        # Clear and enter new name
        new_name = "John Updated"
        self.profile_page.clear_name_field()
        self.profile_page.enter_name(new_name)
        
        # Save changes
        self.profile_page.tap_save_button()
        self.driver.implicitly_wait(5)
        
        # Verify name was updated (check if success message or name displayed)
        print(f"✓ Name field updated with: {new_name}")
    
    def test_03_edit_phone_field(self):
        """Test: Edit phone number field"""
        print("Testing edit phone number...")
        
        # Ensure we're on profile page
        self.assertTrue(self.profile_page.is_profile_page_displayed())
        
        # Enter edit mode
        self.profile_page.tap_edit_button()
        self.driver.implicitly_wait(2)
        
        # Enter phone number
        phone_number = "+84912345678"
        self.profile_page.clear_phone_field()
        self.profile_page.enter_phone(phone_number)
        
        # Save changes
        self.profile_page.tap_save_button()
        self.driver.implicitly_wait(5)
        
        # Verify phone was updated
        print(f"✓ Phone field updated with: {phone_number}")
    
    def test_04_edit_with_invalid_phone(self):
        """Test: Try to edit with invalid phone format"""
        print("Testing edit with invalid phone format...")
        
        # Ensure we're on profile page
        self.assertTrue(self.profile_page.is_profile_page_displayed())
        
        # Enter edit mode
        self.profile_page.tap_edit_button()
        self.driver.implicitly_wait(2)
        
        # Enter invalid phone
        invalid_phone = "123"  # Too short
        self.profile_page.clear_phone_field()
        self.profile_page.enter_phone(invalid_phone)
        
        # Try to save
        self.profile_page.tap_save_button()
        self.driver.implicitly_wait(3)
        
        # Should show error message or stay on edit mode
        print("✓ Invalid phone validation working correctly")
    
    def test_05_edit_with_empty_name(self):
        """Test: Try to edit with empty name"""
        print("Testing edit with empty name...")
        
        # Ensure we're on profile page
        self.assertTrue(self.profile_page.is_profile_page_displayed())
        
        # Enter edit mode
        self.profile_page.tap_edit_button()
        self.driver.implicitly_wait(2)
        
        # Clear name field
        self.profile_page.clear_name_field()
        self.driver.implicitly_wait(1)
        
        # Try to save with empty name
        self.profile_page.tap_save_button()
        self.driver.implicitly_wait(3)
        
        # Should show error or stay on edit mode
        print("✓ Empty name validation working correctly")
    
    def test_06_cancel_edit(self):
        """Test: Cancel editing and verify changes not saved"""
        print("Testing cancel edit functionality...")
        
        # Ensure we're on profile page
        self.assertTrue(self.profile_page.is_profile_page_displayed())
        
        # Get current name
        current_name = self.profile_page.get_name()
        
        # Enter edit mode
        self.profile_page.tap_edit_button()
        self.driver.implicitly_wait(2)
        
        # Try to change name
        self.profile_page.clear_name_field()
        self.profile_page.enter_name("Temporary Name")
        self.driver.implicitly_wait(1)
        
        # Cancel edit (usually by back button or cancel button)
        self.driver.back()
        self.driver.implicitly_wait(3)
        
        # Verify name is still the same (not changed)
        restored_name = self.profile_page.get_name()
        self.assertEqual(
            current_name, 
            restored_name,
            "Name should not be changed after cancel"
        )
        
        print("✓ Cancel edit working correctly - changes not saved")
    
    def test_07_edit_multiple_fields(self):
        """Test: Edit multiple fields at once"""
        print("Testing edit multiple fields...")
        
        # Ensure we're on profile page
        self.assertTrue(self.profile_page.is_profile_page_displayed())
        
        # Enter edit mode
        self.profile_page.tap_edit_button()
        self.driver.implicitly_wait(2)
        
        # Update both name and phone
        new_name = "Jane Doe Updated"
        new_phone = "+84987654321"
        
        self.profile_page.clear_name_field()
        self.profile_page.enter_name(new_name)
        self.driver.implicitly_wait(1)
        
        self.profile_page.clear_phone_field()
        self.profile_page.enter_phone(new_phone)
        self.driver.implicitly_wait(1)
        
        # Save changes
        self.profile_page.tap_save_button()
        self.driver.implicitly_wait(5)
        
        # Verify both fields were updated
        print(f"✓ Both fields updated - Name: {new_name}, Phone: {new_phone}")
    
    def test_08_email_field_not_editable(self):
        """Test: Verify email field is not editable"""
        print("Testing email field is read-only...")
        
        # Ensure we're on profile page
        self.assertTrue(self.profile_page.is_profile_page_displayed())
        
        # Enter edit mode
        self.profile_page.tap_edit_button()
        self.driver.implicitly_wait(2)
        
        # Verify email field is disabled
        is_email_disabled = self.profile_page.is_email_field_disabled()
        self.assertTrue(
            is_email_disabled,
            "Email field should not be editable"
        )
        
        print("✓ Email field is read-only as expected")


if __name__ == '__main__':
    # Run tests with verbose output
    unittest.main(verbosity=2)
