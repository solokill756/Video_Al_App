"""
Login Test Cases
E2E tests for Login functionality
"""
import unittest
import sys
import os

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config.test_config import TestConfig
from page_objects.login_page import LoginPage
from page_objects.register_page import RegisterPage


class LoginTests(unittest.TestCase):
    """Test cases for Login functionality"""
    
    driver = None  # Shared driver for all tests
    login_page = None
    
    @classmethod
    def setUpClass(cls):
        """Setup before all tests - Create driver once"""
        print("\n=== Starting Login Test Suite ===")
        # Initialize driver once for all tests
        cls.driver = TestConfig.create_android_driver()
        cls.login_page = LoginPage(cls.driver)
        cls.driver.implicitly_wait(10)
    
    @classmethod
    def tearDownClass(cls):
        """Cleanup after all tests - Quit driver once"""
        if cls.driver:
            try:
                cls.driver.quit()
                print("\n=== Login Test Suite Completed ===")
            except:
                pass
    
    def setUp(self):
        """Setup before each test - Just clear form, don't restart app"""
        print(f"\n--- Running test: {self._testMethodName} ---")
        try:
            import time
            # Clear email and password fields (don't restart app)
            elements = self.driver.find_elements("class name", "android.widget.EditText")
            for element in elements:
                try:
                    element.clear()
                except:
                    pass
            print("✓ Form cleared - ready for test")
        except Exception as e:
            print(f"⚠️  Warning during setup: {e}")
    
    def tearDown(self):
        """Cleanup after each test"""
        if self.driver:
            # Take screenshot on failure
            if hasattr(self._outcome, 'errors'):
                # Check if test failed
                result = self.defaultTestResult()
                self._feedErrorsToResult(result, self._outcome.errors)
                error = self.list2reason(result.errors)
                failure = self.list2reason(result.failures)
                if error or failure:
                    test_name = self._testMethodName
                    screenshot_name = f"screenshots/login_test_{test_name}_failed.png"
                    os.makedirs("screenshots", exist_ok=True)
                    self.driver.save_screenshot(screenshot_name)
                    print(f"Screenshot saved: {screenshot_name}")
            
            # Don't quit driver - keep it for next test
            # self.driver.quit()  # Commented out - driver quits in tearDownClass
    
    def list2reason(self, exc_list):
        """Helper to check test result"""
        if exc_list and exc_list[-1][0] is self:
            return exc_list[-1][1]
        return None
    
    def test_01_login_page_displayed(self):
        """Test: Verify Login page is displayed on app launch"""
        print("Verifying Login page is displayed...")
        
        # Verify login page elements are present
        self.assertTrue(
            self.login_page.is_login_page_displayed(),
            "Login page is not displayed"
        )
        print("✓ Login page is displayed successfully")
    
    def test_02_login_with_invalid_email(self):
        """Test: Login with invalid email format"""
        print("Testing login with invalid email...")
        
        self.assertTrue(self.login_page.is_login_page_displayed())
        
        # Complete login flow with invalid email
        self.login_page.enter_email(TestConfig.INVALID_EMAIL)
        self.login_page.enter_password(TestConfig.VALID_PASSWORD)
        self.login_page.hide_keyboard()
        self.login_page.tap_login_button()
        
        # Verify still on login page (login failed)
        self.driver.implicitly_wait(5)
        self.assertTrue(
            self.login_page.is_login_page_displayed(),
            "Should still be on login page after invalid email"
        )
        
        print("✓ Invalid email validation working correctly")
    
    def test_03_login_with_empty_email(self):
        """Test: Login with empty email field"""
        print("Testing login with empty email...")
        
        self.assertTrue(self.login_page.is_login_page_displayed())
        
        # Complete login flow with empty email
        self.login_page.enter_email("")
        self.login_page.enter_password(TestConfig.VALID_PASSWORD)
        self.login_page.hide_keyboard()
        self.login_page.tap_login_button()
        
        # Verify error message or still on login page
        self.driver.implicitly_wait(3)
        self.assertTrue(
            self.login_page.is_login_page_displayed(),
            "Should still be on login page after empty email"
        )
        
        print("✓ Empty email validation working correctly")
    
    def test_04_login_with_empty_password(self):
        """Test: Login with empty password field"""
        print("Testing login with empty password...")
        
        self.assertTrue(self.login_page.is_login_page_displayed())
        
        # Complete login flow with empty password
        self.login_page.enter_email(TestConfig.VALID_EMAIL)
        self.login_page.enter_password("")
        self.login_page.hide_keyboard()
        self.login_page.tap_login_button()
        
        # Verify error message or still on login page
        self.driver.implicitly_wait(3)
        self.assertTrue(
            self.login_page.is_login_page_displayed(),
            "Should still be on login page after empty password"
        )
        
        print("✓ Empty password validation working correctly")
    
    def test_05_login_with_wrong_password(self):
        """Test: Login with wrong password"""
        print("Testing login with wrong password...")
        
        self.assertTrue(self.login_page.is_login_page_displayed())
        
        # Try login with wrong password
        self.login_page.login(
            TestConfig.VALID_EMAIL,
            TestConfig.WRONG_PASSWORD
        )
        
        # Verify error message or still on login page
        self.driver.implicitly_wait(5)
        self.assertTrue(
            self.login_page.is_login_page_displayed(),
            "Should still be on login page after wrong password"
        )
        
        print("✓ Wrong password handled correctly")
    
    
    def test_06_login_with_valid_credentials(self):
        """Test: Login with valid email and password - RUN LAST"""
        print("Testing login with valid credentials...")
        print("⚠️  This test runs LAST because login success navigates away from login page")
        
        # Ensure we're on login page
        self.assertTrue(self.login_page.is_login_page_displayed())
        
        # Perform login
        self.login_page.login(
            TestConfig.VALID_EMAIL,
            TestConfig.VALID_PASSWORD
        )
        
        # Verify login was successful (navigated away from login page)
        # is_login_successful() already waits 3s and checks if we left login page
        success = self.login_page.is_login_successful()
        self.assertTrue(success, "Login failed - still on login page or error occurred")
        
        print("✅ Login successful - navigated to home screen")
        print("✅ This was the LAST test - login succeeded and left login page")


if __name__ == '__main__':
    # Run tests with verbose output
    unittest.main(verbosity=2)
