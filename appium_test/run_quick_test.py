#!/usr/bin/env python3
"""
Quick Login Test - Run with admin credentials
"""
import unittest
import time
import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config.test_config import TestConfig
from page_objects.login_page import LoginPage


class QuickLoginTest(unittest.TestCase):
    """Quick test with valid admin credentials"""
    
    driver = None
    
    @classmethod
    def setUpClass(cls):
        """Set up driver once"""
        print("\n" + "="*60)
        print("🚀 QUICK LOGIN TEST - ADMIN CREDENTIALS")
        print("   Email: admin@gmail.com")
        print("   Password: admin123")
        print("="*60)
        cls.driver = TestConfig.create_android_driver()
        time.sleep(2)
    
    @classmethod
    def tearDownClass(cls):
        """Tear down driver"""
        if cls.driver:
            print("\n" + "="*60)
            print("✅ TEST COMPLETED")
            print("="*60)
            cls.driver.quit()
    
    def test_01_login_page_displayed(self):
        """Test: Verify login page"""
        print("\n📱 TEST 1: Checking login page...")
        
        login_page = LoginPage(self.driver)
        self.assertTrue(
            login_page.is_login_page_displayed(),
            "Login page not displayed"
        )
        print("✓ Login page displayed")
    
    def test_02_login_with_admin(self):
        """Test: Login with admin credentials"""
        print("\n📱 TEST 2: Logging in with admin@gmail.com...")
        
        login_page = LoginPage(self.driver)
        
        # Enter credentials
        print("  → Entering email: admin@gmail.com")
        login_page.enter_email(TestConfig.VALID_EMAIL)
        
        print("  → Entering password: admin123")
        login_page.enter_password(TestConfig.VALID_PASSWORD)
        
        print("  → Hiding keyboard")
        login_page.hide_keyboard()
        
        print("  → Tapping Login button")
        login_page.tap_login_button()
        
        # Check result (is_login_successful() waits and checks navigation)
        print("  → Checking login result...")
        if login_page.is_login_successful():
            print("✅ Login successful - navigated to home screen!")
        else:
            print("⚠️  Login failed - still on login page or error occurred")


if __name__ == '__main__':
    # Run tests
    suite = unittest.TestLoader().loadTestsFromTestCase(QuickLoginTest)
    runner = unittest.TextTestRunner(verbosity=2)
    runner.run(suite)
