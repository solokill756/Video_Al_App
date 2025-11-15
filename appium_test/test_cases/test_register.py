"""
Register Test Cases
E2E tests for Registration functionality
"""
import unittest
import sys
import os

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config.test_config import TestConfig
from page_objects.register_page import RegisterPage
from page_objects.register_detail_page import RegisterDetailPage
from page_objects.login_page import LoginPage


class RegisterTests(unittest.TestCase):
    """Test cases for Registration functionality"""
    
    driver = None
    login_page = None
    register_page = None
    register_detail = None
    
    @classmethod
    def setUpClass(cls):
        """Setup before all tests - create shared driver"""
        print("\n=== Starting Register Test Suite ===")
        cls.driver = TestConfig.create_android_driver()
        cls.login_page = LoginPage(cls.driver)
        cls.register_page = RegisterPage(cls.driver)
        cls.register_detail = RegisterDetailPage(cls.driver)
        
        # Initial setup - go to login page
        cls.driver.implicitly_wait(10)
        print("✓ Shared driver initialized")
    
    @classmethod
    def tearDownClass(cls):
        """Cleanup after all tests"""
        if cls.driver:
            cls.driver.quit()
            print("\n=== Register Test Suite Completed ===")
    
    def setUp(self):
        """Setup before each test"""
        print(f"\n--- Running test: {self._testMethodName} ---")
        
        # Reinitialize page objects with shared driver
        self.driver = RegisterTests.driver
        self.login_page = RegisterTests.login_page
        self.register_page = RegisterTests.register_page
        self.register_detail = RegisterTests.register_detail
        
        # Navigate to register page if not already there
        try:
            if self.login_page.is_login_page_displayed():
                print("✓ Form cleared - ready for test")
                self.login_page.tap_register_link()
                self.driver.implicitly_wait(5)
        except:
            pass
    
    def tearDown(self):
        """Cleanup after each test - no driver quit"""
        # Don't quit driver - it's shared for all tests
        pass
    
    def test_01_register_page_displayed(self):
        """Test: Verify Register page is displayed"""
        print("Verifying Register page is displayed...")
        
        # Verify register page elements are present
        self.assertTrue(
            self.register_page.is_register_page_displayed(),
            "Register page is not displayed"
        )
        print("✓ Register page is displayed successfully")
    
    def test_02_register_with_valid_email(self):
        """Test: Enter valid email and continue to detail page"""
        print("Testing registration with valid email...")
        
        # Ensure we're on register page
        self.assertTrue(self.register_page.is_register_page_displayed())
        
        # Enter email and continue
        self.register_page.enter_email_and_continue(TestConfig.VALID_EMAIL)
        
        # Wait for navigation to register detail page
        self.driver.implicitly_wait(10)
        
        # Verify we're on register detail page
        self.assertTrue(
            self.register_detail.is_register_detail_page_displayed(),
            "Should navigate to Register Detail page"
        )
        
        print("✓ Successfully navigated to Register Detail page")
    
    def test_03_register_with_invalid_email(self):
        """Test: Try to register with invalid email format"""
        print("Testing registration with invalid email...")
        
        # Navigate back to register page
        if not self.register_page.is_register_page_displayed():
            self.driver.back()
            self.driver.implicitly_wait(3)
        
        self.assertTrue(self.register_page.is_register_page_displayed())
        
        # Try with invalid email
        self.register_page.enter_email("invalid-email")
        self.register_page.tap_continue_button()
        
        # Verify still on register page (validation failed)
        self.driver.implicitly_wait(5)
        self.assertTrue(
            self.register_page.is_register_page_displayed(),
            "Should still be on register page after invalid email"
        )
        
        print("✓ Invalid email validation working correctly")
    
    def test_04_register_with_empty_email(self):
        """Test: Try to register with empty email"""
        print("Testing registration with empty email...")
        
        # Navigate back to register page if needed
        if not self.register_page.is_register_page_displayed():
            self.driver.back()
            self.driver.implicitly_wait(3)
        
        self.assertTrue(self.register_page.is_register_page_displayed())
        
        # Try with empty email
        self.register_page.enter_email("")
        self.register_page.tap_continue_button()
        
        # Verify still on register page
        self.driver.implicitly_wait(3)
        self.assertTrue(
            self.register_page.is_register_page_displayed(),
            "Should still be on register page after empty email"
        )
        
        print("✓ Empty email validation working correctly")


if __name__ == '__main__':
    # Run tests with verbose output
    unittest.main(verbosity=2)
