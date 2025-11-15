"""
Settings Page Object Model
Contains all elements and actions for Settings Page
"""
from page_objects.base_page import BasePage
from config.speed_config import SpeedConfig
import time


class SettingsPage(BasePage):
    # Text labels
    PAGE_TITLE = "Cài đặt"
    PROFILE_SECTION_TEXT = "Profile"
    PROFILE_BUTTON_TEXT = "Profile"
    LOGOUT_BUTTON_TEXT = "Logout"
    
    def __init__(self, driver):
        super().__init__(driver)
    
    def is_settings_page_displayed(self):
        """Verify Settings page is displayed"""
        try:
            # Check for Vietnamese settings title
            return self.is_text_present(self.PAGE_TITLE)
        except:
            return False
    
    def tap_profile_section(self):
        """Tap on Profile section to go to Profile page"""
        try:
            # Try to find profile button/section
            self.tap_by_text(self.PROFILE_BUTTON_TEXT)
            self.wait(SpeedConfig.get_delay())
        except:
            # Fallback: Look for profile icon or button
            try:
                profile_button = self.driver.find_element(
                    "xpath",
                    "//android.widget.Button[contains(@text, 'Profile')]"
                )
                self.tap_element(profile_button)
                self.wait(SpeedConfig.get_delay())
            except:
                raise Exception("Profile section not found in Settings")
    
    def tap_logout(self):
        """Tap on Logout button"""
        self.tap_by_text(self.LOGOUT_BUTTON_TEXT)
        self.wait(SpeedConfig.get_delay())
    
    def scroll_to_profile(self):
        """Scroll down to find Profile section"""
        try:
            self.scroll_down_action(distance=0.3)
            self.wait(0.5)
        except:
            pass
    
    def wait(self, seconds):
        """Wait for specified seconds"""
        time.sleep(seconds)
