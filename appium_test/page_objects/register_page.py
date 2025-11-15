"""
Register Page Object Model
Contains all elements and actions for Register Page (Email entry)
"""
from page_objects.base_page import BasePage


class RegisterPage(BasePage):
    # Text labels
    PAGE_TITLE = "Create Account"
    SUBTITLE_TEXT = "Enter email to begin registration"
    CONTINUE_BUTTON_TEXT = "Continue"
    LOGIN_LINK_TEXT = "Log in"
    GOOGLE_SIGNIN_TEXT = "Sign in with Google"
    ALREADY_HAVE_ACCOUNT = "Already have an account?"
    
    def __init__(self, driver):
        super().__init__(driver)
    
    def is_register_page_displayed(self):
        """Verify Register page is displayed"""
        try:
            return (self.is_text_present(self.PAGE_TITLE) or 
                   self.is_text_present(self.SUBTITLE_TEXT))
        except:
            return False
    
    def enter_email(self, email):
        """Enter email in email field"""
        try:
            # Find email input field
            element = self.driver.find_element("xpath", 
                "//android.widget.EditText[contains(@content-desc, 'email')]")
            self.enter_text(element, email)
        except:
            # Fallback: Find first EditText on the page
            elements = self.driver.find_elements("class name", "android.widget.EditText")
            if elements:
                self.enter_text(elements[0], email)
            else:
                raise Exception("Email field not found on Register page")
        
        # Hide keyboard after entering email
        try:
            self.hide_keyboard()
        except:
            pass
    
    def tap_continue_button(self):
        """Tap on Continue button"""
        try:
            self.tap_by_text(self.CONTINUE_BUTTON_TEXT)
        except:
            # Fallback: Find button
            buttons = self.driver.find_elements("class name", "android.widget.Button")
            for button in buttons:
                if "continue" in button.text.lower():
                    self.tap_element(button)
                    return
            raise Exception("Continue button not found")
    
    def tap_login_link(self):
        """Tap on Login link"""
        self.tap_by_text(self.LOGIN_LINK_TEXT)
    
    def tap_google_signin(self):
        """Tap on Google Sign In button"""
        self.tap_by_text(self.GOOGLE_SIGNIN_TEXT)
    
    def enter_email_and_continue(self, email):
        """Enter email and tap continue"""
        self.enter_email(email)
        self.hide_keyboard()
        self.wait(1)
        self.tap_continue_button()
