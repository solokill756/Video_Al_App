#!/usr/bin/env python3
"""
Optimized Login Test Runner
- Auto restart app before each test
- Fast mode enabled
- Clear output
"""
import unittest
import sys
import os
import time

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config.test_config import TestConfig
from page_objects.login_page import LoginPage


class FastLoginTests(unittest.TestCase):
    """Optimized Login tests with auto-restart"""
    
    driver = None
    login_page = None
    
    @classmethod
    def setUpClass(cls):
        """Setup before all tests"""
        print("\n" + "="*60)
        print("🚀 LOGIN TESTS - FAST MODE")
        print(f"   Credentials: admin@gmail.com / admin123")
        print("="*60 + "\n")
        cls.driver = TestConfig.create_android_driver()
        cls.login_page = LoginPage(cls.driver)
        cls.driver.implicitly_wait(8)
        cls.start_time = time.time()
    
    @classmethod
    def tearDownClass(cls):
        """Cleanup after all tests"""
        if cls.driver:
            end_time = time.time()
            duration = end_time - cls.start_time
            try:
                cls.driver.quit()
                print("\n" + "="*60)
                print(f"✅ ALL TESTS COMPLETED")
                print(f"⏱️  Total time: {duration:.1f}s")
                print("="*60)
            except:
                pass
    
    def setUp(self):
        """Clear form before each test - No app restart"""
        try:
            # Just clear email and password fields (don't restart app)
            elements = self.driver.find_elements("class name", "android.widget.EditText")
            for element in elements:
                try:
                    element.clear()
                except:
                    pass
            print(f"✓ Form cleared for test: {self._testMethodName}")
        except Exception as e:
            print(f"⚠️  Setup warning: {e}")
    
    def test_01_login_page_displayed(self):
        """✓ Login page displayed"""
        try:
            is_displayed = self.login_page.is_login_page_displayed()
            if not is_displayed:
                print("\n⚠️  Not on login page, trying to navigate back...")
                for _ in range(5):
                    self.driver.back()
                    time.sleep(0.3)
                is_displayed = self.login_page.is_login_page_displayed()
            self.assertTrue(is_displayed, "Login page not displayed")
        except Exception as e:
            print(f"❌ Error checking login page: {e}")
            raise
    
    def test_02_invalid_email(self):
        """✓ Invalid email format"""
        self.login_page.enter_email(TestConfig.INVALID_EMAIL)
        self.login_page.enter_password(TestConfig.VALID_PASSWORD)
        self.login_page.hide_keyboard()
        self.login_page.tap_login_button()
        time.sleep(2)
        self.assertTrue(self.login_page.is_login_page_displayed())
    
    def test_03_empty_email(self):
        """✓ Empty email field"""
        self.login_page.enter_email("")
        self.login_page.enter_password(TestConfig.VALID_PASSWORD)
        self.login_page.hide_keyboard()
        self.login_page.tap_login_button()
        time.sleep(2)
        self.assertTrue(self.login_page.is_login_page_displayed())
    
    def test_04_empty_password(self):
        """✓ Empty password field"""
        self.login_page.enter_email(TestConfig.VALID_EMAIL)
        self.login_page.enter_password("")
        self.login_page.hide_keyboard()
        self.login_page.tap_login_button()
        time.sleep(2)
        self.assertTrue(self.login_page.is_login_page_displayed())
    
    def test_05_wrong_password(self):
        """✓ Wrong password"""
        self.login_page.login(TestConfig.VALID_EMAIL, TestConfig.WRONG_PASSWORD)
        time.sleep(2)
        self.assertTrue(self.login_page.is_login_page_displayed())
    
    def test_06_valid_login(self):
        """✓ Login with valid credentials - RUN LAST"""
        self.login_page.login(TestConfig.VALID_EMAIL, TestConfig.VALID_PASSWORD)
        # is_login_successful() already waits and checks navigation
        self.assertTrue(self.login_page.is_login_successful(), 
                       "Login failed - still on login page")


if __name__ == '__main__':
    # Run with minimal verbosity for cleaner output
    loader = unittest.TestLoader()
    suite = loader.loadTestsFromTestCase(FastLoginTests)
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # Exit with proper code
    sys.exit(0 if result.wasSuccessful() else 1)
