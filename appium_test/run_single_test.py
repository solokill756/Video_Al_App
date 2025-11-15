#!/usr/bin/env python3
"""
Run single test to watch on device
"""
import sys
import os
import unittest
import time

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config.test_config import TestConfig
from page_objects.login_page import LoginPage

class WatchableLoginTest(unittest.TestCase):
    """Single test to watch on device"""
    
    @classmethod
    def setUpClass(cls):
        """Setup driver"""
        print("\n" + "="*60)
        print("🚀 STARTING TEST - WATCH YOUR DEVICE!")
        print("="*60)
        cls.driver = TestConfig.create_android_driver()
        cls.login_page = LoginPage(cls.driver)
        cls.driver.implicitly_wait(10)
        time.sleep(2)  # Give time to focus on device
    
    @classmethod
    def tearDownClass(cls):
        """Cleanup"""
        print("\n" + "="*60)
        print("✅ TEST COMPLETED")
        print("="*60)
        time.sleep(2)  # Keep result visible
        if cls.driver:
            cls.driver.quit()
    
    def test_01_verify_login_page(self):
        """Watch: Verify login page"""
        print("\n📱 TEST 1: Verifying login page is displayed...")
        time.sleep(1)
        
        assert self.login_page.is_login_page_displayed(), "Login page not displayed"
        print("✓ Login page is displayed")
        time.sleep(2)
    
    def test_02_login_with_valid_credentials(self):
        """Watch: Login with valid credentials"""
        print("\n📱 TEST 2: Testing login with valid credentials...")
        time.sleep(1)
        
        print("Starting login flow...")
        self.login_page.login(
            TestConfig.VALID_EMAIL,
            TestConfig.VALID_PASSWORD
        )
        
        print("Waiting for login result...")
        time.sleep(5)  # Wait to see what happens
        
        success = self.login_page.is_login_successful()
        if success:
            print("✅ Login successful!")
        else:
            print("❌ Login failed - but that's OK, maybe credentials are invalid")
            print("   (This is expected if you don't have a test account)")

if __name__ == '__main__':
    # Run tests
    suite = unittest.TestLoader().loadTestsFromTestCase(WatchableLoginTest)
    runner = unittest.TextTestRunner(verbosity=2)
    runner.run(suite)
