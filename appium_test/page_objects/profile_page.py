"""
Profile Page Object Model
Contains all elements and actions for Profile Page (Edit user profile)
"""
from page_objects.base_page import BasePage
from config.speed_config import SpeedConfig
import time


class ProfilePage(BasePage):
    # Text labels
    PAGE_TITLE = "Profile"
    EDIT_BUTTON_TEXT = "Edit"
    SAVE_BUTTON_TEXT = "Save"
    CANCEL_BUTTON_TEXT = "Cancel"
    
    # Field labels
    NAME_LABEL = "Full Name"
    EMAIL_LABEL = "Email"
    PHONE_LABEL = "Phone Number"
    
    def __init__(self, driver):
        super().__init__(driver)
    
    def is_profile_page_displayed(self):
        """Verify Profile page is displayed"""
        try:
            return self.is_text_present(self.PAGE_TITLE)
        except:
            return False
    
    def navigate_to_profile(self):
        """Navigate to profile page from home/menu"""
        try:
            # This depends on app navigation - usually through menu
            # For now, just check if we can find the profile icon or link
            profile_icon = self.driver.find_element(
                "xpath",
                "//android.widget.ImageView[contains(@content-desc, 'profile')]"
            )
            self.tap_element(profile_icon)
            self.wait(2)
        except:
            # Fallback: Try to find profile button in app bar
            try:
                profile_button = self.driver.find_element(
                    "xpath",
                    "//android.widget.Button[contains(@text, 'Profile')]"
                )
                self.tap_element(profile_button)
                self.wait(2)
            except:
                raise Exception("Cannot navigate to profile page")
    
    def tap_edit_button(self):
        """Tap on Edit button to enable editing"""
        self.tap_by_text(self.EDIT_BUTTON_TEXT)
        self.wait(SpeedConfig.get_delay())
    
    def tap_save_button(self):
        """Tap on Save button to save changes"""
        self.tap_by_text(self.SAVE_BUTTON_TEXT)
        self.wait(SpeedConfig.get_delay())
    
    def tap_cancel_button(self):
        """Tap on Cancel button to discard changes"""
        self.tap_by_text(self.CANCEL_BUTTON_TEXT)
        self.wait(SpeedConfig.get_delay())
    
    def get_name(self):
        """Get current name value"""
        try:
            elements = self.driver.find_elements("class name", "android.widget.EditText")
            if elements:
                # Name is usually the first field
                return elements[0].text
        except:
            pass
        return ""
    
    def enter_name(self, name):
        """Enter name in name field"""
        try:
            # Find name field (usually first EditText)
            elements = self.driver.find_elements("class name", "android.widget.EditText")
            if elements:
                self.enter_text(elements[0], name)
                self.hide_keyboard()
        except:
            raise Exception("Name field not found")
    
    def clear_name_field(self):
        """Clear the name field"""
        try:
            elements = self.driver.find_elements("class name", "android.widget.EditText")
            if elements:
                field = elements[0]
                field.click()
                # Select all and delete
                field.send_keys('\u0001')  # Ctrl+A
                field.send_keys('\ue008')  # Backspace
        except:
            raise Exception("Name field not found")
    
    def get_phone(self):
        """Get current phone number value"""
        try:
            elements = self.driver.find_elements("class name", "android.widget.EditText")
            if len(elements) >= 3:
                # Phone is usually the third field
                return elements[2].text
        except:
            pass
        return ""
    
    def enter_phone(self, phone):
        """Enter phone number in phone field"""
        try:
            elements = self.driver.find_elements("class name", "android.widget.EditText")
            if len(elements) >= 3:
                # Phone field is usually the third EditText
                self.enter_text(elements[2], phone)
                self.hide_keyboard()
            else:
                raise Exception("Phone field not found - not enough fields")
        except Exception as e:
            raise Exception(f"Phone field error: {str(e)}")
    
    def clear_phone_field(self):
        """Clear the phone field"""
        try:
            elements = self.driver.find_elements("class name", "android.widget.EditText")
            if len(elements) >= 3:
                field = elements[2]
                field.click()
                # Select all and delete
                field.send_keys('\u0001')  # Ctrl+A
                field.send_keys('\ue008')  # Backspace
        except:
            raise Exception("Phone field not found")
    
    def is_email_field_disabled(self):
        """Check if email field is disabled (read-only)"""
        try:
            elements = self.driver.find_elements("class name", "android.widget.EditText")
            if len(elements) >= 2:
                # Email is usually the second field
                email_field = elements[1]
                # Check if enabled attribute is false
                is_enabled = email_field.get_attribute("enabled")
                return is_enabled == "false" or is_enabled == False
        except:
            pass
        return False
    
    def get_email(self):
        """Get current email value"""
        try:
            elements = self.driver.find_elements("class name", "android.widget.EditText")
            if len(elements) >= 2:
                # Email is usually the second field
                return elements[1].text
        except:
            pass
        return ""
    
    def is_edit_mode_active(self):
        """Check if currently in edit mode"""
        try:
            # In edit mode, we should see Save button instead of Edit button
            return self.is_text_present(self.SAVE_BUTTON_TEXT)
        except:
            return False
    
    def scroll_down(self, distance=0.3):
        """Scroll down to see more fields"""
        self.scroll_down_action(distance=distance)
    
    def wait(self, seconds):
        """Wait for specified seconds"""
        time.sleep(seconds)
    
    def is_error_message_shown(self):
        """Check if error message is displayed"""
        try:
            # Look for common error indicators
            error_texts = ["cannot be empty", "invalid", "error", "failed"]
            for text in error_texts:
                if self.is_text_present(text, timeout=3):
                    return True
            
            # Also check for snackbar or toast with error
            # Snackbars typically appear at bottom
            snackbars = self.driver.find_elements("xpath", 
                "//android.widget.FrameLayout[contains(@resource-id, 'snackbar')]")
            return len(snackbars) > 0
        except:
            return False
    
    def is_success_message_shown(self):
        """Check if success message is displayed"""
        try:
            # Look for common success indicators
            success_texts = ["successfully", "updated", "saved", "success"]
            for text in success_texts:
                if self.is_text_present(text, timeout=3):
                    return True
            
            # Check for green snackbar or toast
            return False
        except:
            return False

