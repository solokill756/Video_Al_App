"""
Register Detail Page Object Model
Contains all elements and actions for Register Detail Page (Complete registration)
"""
from page_objects.base_page import BasePage


class RegisterDetailPage(BasePage):
    # Text labels
    PAGE_TITLE = "Complete Registration"
    SUBTITLE_TEXT = "Please fill in the details below to create your account"
    SUBMIT_BUTTON_TEXT = "Complete Registration"
    RESEND_BUTTON_TEXT = "Gửi lại"
    SIGN_IN_LINK_TEXT = "Sign In"
    
    # Labels
    EMAIL_LABEL = "Email"
    OTP_LABEL = "OTP Code"
    NAME_LABEL = "Full Name"
    PHONE_LABEL = "Phone Number"
    PASSWORD_LABEL = "Password"
    CONFIRM_PASSWORD_LABEL = "Confirm Password"
    
    def __init__(self, driver):
        super().__init__(driver)
    
    def is_register_detail_page_displayed(self):
        """Verify Register Detail page is displayed"""
        try:
            return (self.is_text_present(self.PAGE_TITLE) or 
                   self.is_text_present(self.SUBMIT_BUTTON_TEXT))
        except:
            return False
    
    def enter_otp(self, otp):
        """Enter OTP code"""
        try:
            # Find OTP field (usually the first EditText)
            elements = self.driver.find_elements("class name", "android.widget.EditText")
            if elements:
                # OTP field is typically after the email display
                # Look for a field that accepts numbers
                for element in elements:
                    # Try to enter text in the first editable field
                    if element.is_enabled():
                        self.enter_text(element, otp)
                        # Hide keyboard
                        try:
                            self.hide_keyboard()
                        except:
                            pass
                        break
        except Exception as e:
            raise Exception(f"OTP field not found: {str(e)}")
    
    def enter_full_name(self, name):
        """Enter full name"""
        try:
            # Find name field - typically after OTP field
            elements = self.driver.find_elements("class name", "android.widget.EditText")
            editable_fields = [el for el in elements if el.is_enabled()]
            if len(editable_fields) >= 2:
                self.enter_text(editable_fields[1], name)
                # Hide keyboard
                try:
                    self.hide_keyboard()
                except:
                    pass
            else:
                raise Exception("Name field not found")
        except Exception as e:
            raise Exception(f"Could not enter name: {str(e)}")
    
    def enter_phone_number(self, phone):
        """Enter phone number"""
        try:
            elements = self.driver.find_elements("class name", "android.widget.EditText")
            editable_fields = [el for el in elements if el.is_enabled()]
            if len(editable_fields) >= 3:
                self.enter_text(editable_fields[2], phone)
                # Hide keyboard
                try:
                    self.hide_keyboard()
                except:
                    pass
            else:
                raise Exception("Phone field not found")
        except Exception as e:
            raise Exception(f"Could not enter phone: {str(e)}")
    
    def enter_password(self, password):
        """Enter password"""
        try:
            elements = self.driver.find_elements("class name", "android.widget.EditText")
            editable_fields = [el for el in elements if el.is_enabled()]
            if len(editable_fields) >= 4:
                self.enter_text(editable_fields[3], password)
                # Hide keyboard
                try:
                    self.hide_keyboard()
                except:
                    pass
            else:
                raise Exception("Password field not found")
        except Exception as e:
            raise Exception(f"Could not enter password: {str(e)}")
    
    def enter_confirm_password(self, password):
        """Enter confirm password"""
        try:
            elements = self.driver.find_elements("class name", "android.widget.EditText")
            editable_fields = [el for el in elements if el.is_enabled()]
            if len(editable_fields) >= 5:
                self.enter_text(editable_fields[4], password)
                # Hide keyboard
                try:
                    self.hide_keyboard()
                except:
                    pass
            else:
                raise Exception("Confirm password field not found")
        except Exception as e:
            raise Exception(f"Could not enter confirm password: {str(e)}")
    
    def tap_resend_otp(self):
        """Tap on Resend OTP button"""
        self.tap_by_text(self.RESEND_BUTTON_TEXT)
    
    def tap_submit_button(self):
        """Tap on Complete Registration button"""
        self.tap_by_text(self.SUBMIT_BUTTON_TEXT)
    
    def tap_sign_in_link(self):
        """Tap on Sign In link"""
        self.tap_by_text(self.SIGN_IN_LINK_TEXT)
    
    def complete_registration(self, otp, name, phone, password):
        """Complete the full registration flow"""
        self.enter_otp(otp)
        self.scroll_down(distance=0.3)
        self.enter_full_name(name)
        self.enter_phone_number(phone)
        self.scroll_down(distance=0.3)
        self.enter_password(password)
        self.enter_confirm_password(password)
        self.hide_keyboard()
        self.scroll_down(distance=0.3)
        self.tap_submit_button()
    
    def is_registration_successful(self):
        """Verify registration was successful"""
        try:
            # Check if redirected back to login page
            return self.is_text_present("Login", timeout=10)
        except:
            return False
