"""
Login Page Object Model
Contains all elements and actions for Login Page
"""
from page_objects.base_page import BasePage


class LoginPage(BasePage):
    # Locators - Using text since Flutter widgets need special handling
    EMAIL_FIELD_LOCATOR = "//android.widget.EditText[contains(@text, 'email') or contains(@content-desc, 'email')]"
    PASSWORD_FIELD_LOCATOR = "//android.widget.EditText[contains(@content-desc, 'password')]"
    LOGIN_BUTTON_TEXT = "Login"
    REGISTER_LINK_TEXT = "Sign up now"
    FORGOT_PASSWORD_TEXT = "Forgot password?"
    
    # Text labels
    PAGE_TITLE = "Login"
    LOGIN_SUCCESS_MESSAGE = "Login successful"
    VIDEOAI_TITLE = "VideoAI"
    LOGIN_TO_ACCOUNT_TEXT = "Login to your account"
    
    def __init__(self, driver):
        super().__init__(driver)
    
    def is_login_page_displayed(self):
        """Verify Login page is displayed"""
        try:
            return (self.is_text_present(self.VIDEOAI_TITLE) or 
                   self.is_text_present(self.LOGIN_TO_ACCOUNT_TEXT) or
                   self.is_text_present(self.PAGE_TITLE))
        except:
            return False
    
    def enter_email(self, email):
        """Enter email in email field"""
        try:
            # Method 1: Find by hint text
            element = self.driver.find_element("xpath", 
                "//android.widget.EditText[contains(@text, 'your@email.com') or contains(@text, 'email')]")
            self.enter_text(element, email)
            print(f"    ✓ Email entered: {email}")
            return
        except:
            pass
        
        try:
            # Method 2: Find all EditText and use the first one (email is usually first)
            elements = self.driver.find_elements("class name", "android.widget.EditText")
            if elements and len(elements) > 0:
                self.enter_text(elements[0], email)
                print(f"    ✓ Email entered: {email}")
                # Hide keyboard after entering email
                try:
                    self.hide_keyboard()
                    print(f"    ✓ Keyboard hidden")
                except:
                    pass
                return
        except:
            pass
        
        raise Exception("❌ Email field not found!")
    
    def enter_password(self, password):
        """Enter password in password field"""
        # Try to find password field (after keyboard is hidden from email)
        try:
            # Find all EditText and use the second one (password is usually second)
            elements = self.driver.find_elements("class name", "android.widget.EditText")
            if len(elements) >= 2:
                self.enter_text(elements[1], password)
                print(f"    ✓ Password entered: {'*' * len(password)}")
                return
        except:
            pass
        
        raise Exception("❌ Password field not found!")
    
    def tap_login_button(self):
        """Tap on Login button"""
        try:
            # Find all Login elements and click the button (usually last one)
            elements = self.driver.find_elements("xpath", "//*[@content-desc='Login']")
            if len(elements) > 1:
                # Multiple "Login" elements found, click the last one (button)
                self.tap_element(elements[-1])
            elif len(elements) == 1:
                self.tap_element(elements[0])
            else:
                raise Exception("Login button not found")
        except Exception as e:
            # Fallback: Find button by class name
            buttons = self.driver.find_elements("class name", "android.widget.Button")
            for button in buttons:
                try:
                    if "login" in button.get_attribute("content-desc").lower():
                        self.tap_element(button)
                        return
                except:
                    pass
            raise Exception(f"Login button not found: {str(e)}")
    
    def tap_register_link(self):
        """Tap on Register link"""
        self.tap_by_text(self.REGISTER_LINK_TEXT)
    
    def tap_forgot_password(self):
        """Tap on Forgot Password link"""
        self.tap_by_text(self.FORGOT_PASSWORD_TEXT)
    
    def login(self, email, password):
        """Complete login flow"""
        self.enter_email(email)
        self.enter_password(password)
        self.hide_keyboard()
        self.tap_login_button()
    
    def is_login_successful(self):
        """Verify login was successful by checking if we left the login page"""
        import time
        # Wait a bit for navigation to complete
        time.sleep(3)
        try:
            # If we're NOT on login page anymore = login succeeded
            is_still_on_login = self.is_login_page_displayed()
            return not is_still_on_login
        except Exception as e:
            # If we can't find login page elements, we've navigated away = success
            return True
    
    def get_error_message(self):
        """Get error message if login fails"""
        try:
            # Look for common error message patterns
            error_element = self.driver.find_element("xpath", 
                "//android.widget.TextView[contains(@text, 'error') or contains(@text, 'Error')]")
            return error_element.text
        except:
            return None
