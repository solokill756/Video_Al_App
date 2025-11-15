#!/usr/bin/env python3
"""
Watchable Register Test - Run with delays so you can see what's happening
"""
import unittest
import time
from config.test_config import TestConfig
from page_objects.register_page import RegisterPage
from page_objects.register_detail_page import RegisterDetailPage


class WatchableRegisterTest(unittest.TestCase):
    """Watchable test cases for Register flow"""
    
    driver = None
    
    @classmethod
    def setUpClass(cls):
        """Set up driver once for all tests"""
        print("\n" + "="*60)
        print("🚀 STARTING REGISTER TEST - WATCH YOUR DEVICE!")
        print("="*60)
        cls.driver = TestConfig.create_android_driver()
        time.sleep(3)  # Wait for app to launch
    
    @classmethod
    def tearDownClass(cls):
        """Tear down driver after all tests"""
        if cls.driver:
            print("\n" + "="*60)
            print("✅ TEST COMPLETED")
            print("="*60)
            cls.driver.quit()
    
    def test_01_verify_register_page(self):
        """Watch: Verify register page"""
        print("\n📱 TEST 1: Verifying register page is displayed...")
        time.sleep(2)
        
        register_page = RegisterPage(self.driver)
        self.assertTrue(
            register_page.is_register_page_displayed(),
            "Register page should be displayed"
        )
        print("✓ Register page is displayed")
        time.sleep(2)
    
    def test_02_enter_email_and_continue(self):
        """Watch: Enter email and continue to detail page"""
        print("\n📱 TEST 2: Testing email entry and continue...")
        time.sleep(2)
        
        register_page = RegisterPage(self.driver)
        
        # Enter email
        print("  → Entering email: test_register@example.com")
        register_page.enter_email("test_register@example.com")
        time.sleep(2)
        
        # Tap continue
        print("  → Tapping Continue button")
        register_page.tap_continue_button()
        time.sleep(5)  # Wait for OTP sending and page transition
        
        # Verify we're on detail page
        detail_page = RegisterDetailPage(self.driver)
        if detail_page.is_register_detail_page_displayed():
            print("✓ Navigated to Register Detail page")
            print("❌ (Cannot complete - need real OTP code)")
        else:
            print("❌ Still on Register page - check if email is valid or backend is working")


if __name__ == '__main__':
    # Run tests
    suite = unittest.TestLoader().loadTestsFromTestCase(WatchableRegisterTest)
    runner = unittest.TextTestRunner(verbosity=2)
    runner.run(suite)
