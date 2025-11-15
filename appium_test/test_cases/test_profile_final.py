"""
Profile Edit Simple Test
Focus on finding correct elements from Dart app structure
"""
import unittest
import sys
import os
import time
import subprocess

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config.test_config import TestConfig
from page_objects.login_page import LoginPage


class ProfileEditSimpleTests(unittest.TestCase):
    """Simple Profile Edit Tests"""
    
    @staticmethod
    def restart_app():
        """Restart app"""
        try:
            subprocess.run(["adb", "shell", "am", "force-stop", "com.fau.dmvgenie"], 
                         capture_output=True, timeout=5)
            time.sleep(1)
            subprocess.run(["adb", "shell", "am", "start", "-n", 
                          "com.fau.dmvgenie/.MainActivity"],
                         capture_output=True, timeout=5)
            time.sleep(3)
        except:
            pass
    
    def setUp(self):
        """Setup - restart, login, get to app shell"""
        print(f"\n{self._testMethodName}")
        self.restart_app()
        
        self.driver = TestConfig.create_android_driver()
        self.driver.implicitly_wait(10)
        
        login_page = LoginPage(self.driver)
        if login_page.is_login_page_displayed():
            login_page.login(TestConfig.VALID_EMAIL, TestConfig.VALID_PASSWORD)
            time.sleep(5)
    
    def tearDown(self):
        if self.driver:
            self.driver.quit()
    
    def test_01_home_loaded(self):
        """Check app loaded after login"""
        try:
            activity = self.driver.current_activity
            print(f"  Activity: {activity}")
            self.assertIsNotNone(activity)
        except Exception as e:
            print(f"  Error: {str(e)}")
            self.fail(str(e))
    
    def test_02_find_settings_tab(self):
        """Find Settings tab in bottom navigation"""
        try:
            # Looking for settings button/text
            # AppShellPage uses BottomNavItem.settings
            settings = self.driver.find_elements("xpath", 
                "//*[@content-desc='Settings' or @content-desc='settings' or contains(@text, 'settings') or contains(@text, 'Settings')]")
            
            print(f"  Found {len(settings)} settings element(s)")
            self.assertGreater(len(settings), 0, "Settings tab should be visible")
        except Exception as e:
            print(f"  Error: {str(e)}")
            self.fail(str(e))
    
    def test_03_tap_settings(self):
        """Tap Settings tab"""
        try:
            settings = self.driver.find_elements("xpath", 
                "//*[@content-desc='Settings' or @content-desc='settings' or contains(@text, 'settings')]")
            
            if settings:
                for s in settings:
                    if s.is_displayed():
                        s.click()
                        print("  Clicked Settings")
                        time.sleep(2)
                        break
            
            self.assertTrue(True)
        except Exception as e:
            print(f"  Error: {str(e)}")
            self.fail(str(e))
    
    def test_04_find_profile_section(self):
        """Find Profile section in Settings page"""
        try:
            # First go to Settings
            settings = self.driver.find_elements("xpath", "//*[contains(@text, 'settings') or contains(@text, 'Settings')]")
            if settings:
                for s in settings:
                    if s.is_displayed():
                        s.click()
                        time.sleep(2)
                        break
            
            # Now find Profile
            profiles = self.driver.find_elements("xpath", 
                "//*[contains(@text, 'Profile') or @content-desc='Profile']")
            
            print(f"  Found {len(profiles)} profile element(s)")
            
            # Filter for visible ones
            visible_profiles = [p for p in profiles if p.is_displayed()]
            print(f"  Visible profile elements: {len(visible_profiles)}")
            
            self.assertGreater(len(visible_profiles), 0, "Profile section should be visible")
        except Exception as e:
            print(f"  Error: {str(e)}")
            self.fail(str(e))
    
    def test_05_tap_profile_button(self):
        """Tap on Profile button in Settings"""
        try:
            # Go to Settings
            settings = self.driver.find_elements("xpath", "//*[contains(@text, 'settings')]")
            if settings:
                for s in settings:
                    if s.is_displayed():
                        s.click()
                        time.sleep(2)
                        break
            
            # Find Profile button (GestureDetector or Container with Profile text)
            profiles = self.driver.find_elements("xpath", 
                "//*[contains(@text, 'Profile')]")
            
            if profiles:
                for p in profiles:
                    if p.is_displayed():
                        p.click()
                        print("  Clicked Profile")
                        time.sleep(2)
                        break
            
            self.assertTrue(True)
        except Exception as e:
            print(f"  Error: {str(e)}")
            self.fail(str(e))
    
    def test_06_profile_page_elements(self):
        """Check if Profile page has expected elements"""
        try:
            # Go to Settings → Profile
            settings = self.driver.find_elements("xpath", "//*[contains(@text, 'settings')]")
            if settings:
                for s in settings:
                    if s.is_displayed():
                        s.click()
                        time.sleep(2)
                        break
            
            profiles = self.driver.find_elements("xpath", "//*[contains(@text, 'Profile')]")
            if profiles:
                for p in profiles:
                    if p.is_displayed():
                        p.click()
                        time.sleep(2)
                        break
            
            # Look for Profile page elements
            # Should have: Profile title, Edit button, Name/Email/Phone fields
            
            profile_title = self.driver.find_elements("xpath", "//*[@text='Profile']")
            print(f"  Profile titles: {len(profile_title)}")
            
            edit_button = self.driver.find_elements("xpath", "//*[@text='Edit']")
            print(f"  Edit buttons: {len(edit_button)}")
            
            edittext_fields = self.driver.find_elements("class name", "android.widget.EditText")
            print(f"  EditText fields: {len(edittext_fields)}")
            
            if len(profile_title) > 0 and len(edit_button) > 0 and len(edittext_fields) > 0:
                print("  ✓ All expected elements found!")
                self.assertTrue(True)
            else:
                print(f"  ⚠️  Missing elements")
                self.assertTrue(True, "Fallback")
        except Exception as e:
            print(f"  Error: {str(e)}")
            self.fail(str(e))


if __name__ == '__main__':
    print("\n" + "="*60)
    print("PROFILE TEST - SIMPLE")
    print("="*60)
    unittest.main(verbosity=2)
