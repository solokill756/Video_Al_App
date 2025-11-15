"""
Simple navigation test - verify we can reach Profile page from Settings
"""
import unittest
import sys
import os
import time
import subprocess

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from config.test_config import TestConfig
from page_objects.login_page import LoginPage


class NavigationTest(unittest.TestCase):
    """Test navigation to Profile page"""
    
    @staticmethod
    def restart_app():
        """Restart app on device"""
        try:
            subprocess.run(["adb", "shell", "am", "force-stop", "com.fau.dmvgenie"],
                         capture_output=True, timeout=5)
            time.sleep(1)
            subprocess.run(["adb", "shell", "am", "start", "-n", "com.fau.dmvgenie/.MainActivity"],
                         capture_output=True, timeout=5)
            time.sleep(3)
        except:
            pass
    
    def setUp(self):
        """Setup"""
        print("\n" + "="*70)
        print("TEST: Navigation to Profile")
        print("="*70)
        
        self.restart_app()
        self.driver = TestConfig.create_android_driver()
        self.driver.implicitly_wait(10)
    
    def tearDown(self):
        """Cleanup"""
        if self.driver:
            self.driver.quit()
    
    def test_01_login(self):
        """Step 1: Login"""
        print("\n⏳ Step 1: Login")
        login_page = LoginPage(self.driver)
        
        if login_page.is_login_page_displayed():
            login_page.login(TestConfig.VALID_EMAIL, TestConfig.VALID_PASSWORD)
            time.sleep(5)
            print("✅ Logged in successfully")
            
            # Print screen info
            activity = self.driver.current_activity
            print(f"   Current activity: {activity}")
        else:
            print("❌ Not on login page")
            self.fail("Not on login page")
    
    def test_02_navigate_to_settings(self):
        """Step 2: Navigate to Settings"""
        print("\n⏳ Step 2: Navigate to Settings")
        
        # First login
        login_page = LoginPage(self.driver)
        if login_page.is_login_page_displayed():
            login_page.login(TestConfig.VALID_EMAIL, TestConfig.VALID_PASSWORD)
            time.sleep(5)
        
        # Find and tap Settings
        settings_buttons = self.driver.find_elements("xpath", 
            "//*[contains(@text, 'Settings') or contains(@text, 'Cài đặt')]")
        
        print(f"   Settings buttons found: {len(settings_buttons)}")
        
        self.assertGreater(len(settings_buttons), 0, "Settings button not found")
        
        for btn in settings_buttons:
            try:
                if btn.is_displayed():
                    btn.click()
                    time.sleep(3)
                    print("✅ Settings tab tapped")
                    
                    # Check Settings page header
                    settings_header = self.driver.find_elements("xpath", "//*[@text='Cài đặt']")
                    print(f"   Settings header found: {len(settings_header)}")
                    break
            except:
                pass
    
    def test_03_navigate_to_profile(self):
        """Step 3: Navigate to Profile from Settings"""
        print("\n⏳ Step 3: Navigate to Profile")
        
        # Login
        login_page = LoginPage(self.driver)
        if login_page.is_login_page_displayed():
            login_page.login(TestConfig.VALID_EMAIL, TestConfig.VALID_PASSWORD)
            time.sleep(5)
        
        # Go to Settings
        settings_buttons = self.driver.find_elements("xpath", 
            "//*[contains(@text, 'Settings') or contains(@text, 'Cài đặt')]")
        if settings_buttons:
            settings_buttons[0].click()
            time.sleep(3)
        
        # Find and tap Profile section (look for forward arrow)
        arrows = self.driver.find_elements("xpath", "//android.widget.ImageView[@content-desc='arrow_forward_ios']")
        print(f"   Forward arrows found: {len(arrows)}")
        
        if arrows:
            arrows[0].click()
            time.sleep(3)
            print("✅ Profile section tapped")
            
            # Check Profile page
            profile_header = self.driver.find_elements("xpath", "//*[@text='Profile']")
            print(f"   Profile header found: {len(profile_header)}")
            
            self.assertGreater(len(profile_header), 0, "Profile page not reached")
            print("✅ Successfully navigated to Profile page!")
        else:
            print("❌ Forward arrow not found")
            self.fail("Forward arrow not found - cannot navigate to Profile")


if __name__ == '__main__':
    unittest.main(verbosity=2)
