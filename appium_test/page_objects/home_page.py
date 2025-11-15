"""
Home Page Object Model
Contains all elements and actions for Home Page
"""
from page_objects.base_page import BasePage
from config.speed_config import SpeedConfig
import time


class HomePage(BasePage):
    # Text labels / Content descriptions
    HOME_TAB_TEXT = "Home"
    UPLOAD_TAB_TEXT = "Upload"
    SETTINGS_TAB_TEXT = "Cài đặt"  # Vietnamese for Settings
    SEARCH_HINT_TEXT = "Search videos"
    
    def __init__(self, driver):
        super().__init__(driver)
    
    def is_home_page_displayed(self):
        """Verify Home page is displayed"""
        try:
            # Check for search or main content
            return self.is_text_present(self.SEARCH_HINT_TEXT) or \
                   self.is_text_present(self.HOME_TAB_TEXT)
        except:
            return False
    
    def tap_settings_tab(self):
        """Tap on Settings tab in bottom navigation"""
        try:
            # Try Vietnamese label first
            self.tap_by_text(self.SETTINGS_TAB_TEXT)
            self.wait(SpeedConfig.get_delay())
        except:
            # Fallback: Look for settings icon
            try:
                settings_icon = self.driver.find_element(
                    "xpath",
                    "//android.widget.ImageView[contains(@content-desc, 'settings') or contains(@content-desc, 'Settings')]"
                )
                self.tap_element(settings_icon)
                self.wait(SpeedConfig.get_delay())
            except:
                # Fallback: Look for settings button in bottom nav
                try:
                    settings_button = self.driver.find_element(
                        "xpath",
                        "//android.widget.FrameLayout[contains(@resource-id, 'settings')]"
                    )
                    self.tap_element(settings_button)
                    self.wait(SpeedConfig.get_delay())
                except:
                    raise Exception("Settings tab not found in navigation")
    
    def tap_upload_tab(self):
        """Tap on Upload tab"""
        self.tap_by_text(self.UPLOAD_TAB_TEXT)
        self.wait(SpeedConfig.get_delay())
    
    def tap_home_tab(self):
        """Tap on Home tab"""
        self.tap_by_text(self.HOME_TAB_TEXT)
        self.wait(SpeedConfig.get_delay())
    
    def search_video(self, keyword):
        """Search for videos"""
        try:
            # Find search field and enter keyword
            search_elements = self.driver.find_elements("class name", "android.widget.EditText")
            if search_elements:
                self.enter_text(search_elements[0], keyword)
                self.hide_keyboard()
                self.wait(1)
        except:
            raise Exception("Search field not found")
    
    def wait(self, seconds):
        """Wait for specified seconds"""
        time.sleep(seconds)
