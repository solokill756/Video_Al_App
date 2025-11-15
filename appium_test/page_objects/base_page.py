"""
Appium Page Object Model - Base Page
Contains common methods for all page objects
"""
from appium import webdriver
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
import time
import sys
import os

# Add config directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'config'))
from speed_config import SpeedConfig


class BasePage:
    def __init__(self, driver):
        self.driver = driver
        timeout = SpeedConfig.get_timeout()
        self.wait = WebDriverWait(driver, timeout)
        self.short_wait = WebDriverWait(driver, max(5, timeout // 2))
    
    def find_element_by_key(self, key, timeout=None):
        """Find element by Flutter Key"""
        if timeout is None:
            timeout = SpeedConfig.get_timeout()
        try:
            locator = (AppiumBy.ACCESSIBILITY_ID, key)
            element = WebDriverWait(self.driver, timeout).until(
                EC.presence_of_element_located(locator)
            )
            return element
        except TimeoutException:
            raise Exception(f"Element with key '{key}' not found within {timeout} seconds")
    
    def find_element_by_text(self, text, timeout=None):
        """Find element by text (for Flutter, uses content-desc)"""
        if timeout is None:
            timeout = SpeedConfig.get_timeout()
        try:
            # Try content-desc first (Flutter)
            locator = (AppiumBy.XPATH, f"//*[@content-desc='{text}']")
            element = WebDriverWait(self.driver, timeout).until(
                EC.presence_of_element_located(locator)
            )
            return element
        except TimeoutException:
            # Fallback to text attribute (native Android)
            try:
                locator = (AppiumBy.XPATH, f"//*[@text='{text}']")
                element = WebDriverWait(self.driver, timeout).until(
                    EC.presence_of_element_located(locator)
                )
                return element
            except TimeoutException:
                raise Exception(f"Element with text/content-desc '{text}' not found within {timeout} seconds")
    
    def tap_element(self, element):
        """Tap on element"""
        element.click()
        time.sleep(SpeedConfig.get_delay('after_action'))
    
    def tap_by_key(self, key, timeout=None):
        """Find and tap element by key"""
        element = self.find_element_by_key(key, timeout)
        self.tap_element(element)
    
    def tap_by_text(self, text, timeout=None):
        """Find and tap element by text"""
        element = self.find_element_by_text(text, timeout)
        self.tap_element(element)
    
    def enter_text(self, element, text):
        """Enter text in element"""
        # Click to focus first
        element.click()
        time.sleep(0.1)  # Minimal wait for focus
        # Clear field (Flutter fields need click first)
        try:
            element.clear()
        except:
            pass  # Some Flutter fields don't support clear()
        # Send keys
        element.send_keys(text)
        time.sleep(SpeedConfig.get_delay('after_action'))
    
    def enter_text_by_key(self, key, text, timeout=30):
        """Find element by key and enter text"""
        element = self.find_element_by_key(key, timeout)
        self.enter_text(element, text)
    
    def is_element_present(self, key, timeout=5):
        """Check if element is present"""
        try:
            self.find_element_by_key(key, timeout)
            return True
        except:
            return False
    
    def is_text_present(self, text, timeout=5):
        """Check if text is present"""
        try:
            self.find_element_by_text(text, timeout)
            return True
        except:
            return False
    
    def wait_for_element(self, key, timeout=30):
        """Wait for element to be present"""
        return self.find_element_by_key(key, timeout)
    
    def hide_keyboard(self):
        """Hide keyboard"""
        try:
            self.driver.hide_keyboard()
            time.sleep(SpeedConfig.get_delay('after_keyboard'))
        except:
            pass
    
    def scroll_down(self, distance=0.7):
        """Scroll down"""
        size = self.driver.get_window_size()
        start_x = size['width'] // 2
        start_y = int(size['height'] * 0.8)
        end_y = int(size['height'] * (1 - distance))
        
        self.driver.swipe(start_x, start_y, start_x, end_y, duration=800)
    
    def scroll_up(self, distance=0.7):
        """Scroll up"""
        size = self.driver.get_window_size()
        start_x = size['width'] // 2
        start_y = int(size['height'] * 0.2)
        end_y = int(size['height'] * distance)
        
        self.driver.swipe(start_x, start_y, start_x, end_y, duration=800)
    
    def take_screenshot(self, filename):
        """Take screenshot"""
        self.driver.save_screenshot(filename)
    
    def sleep(self, seconds):
        """Wait for specific seconds"""
        time.sleep(seconds)
    
    def get_element_text(self, element):
        """Get text from element"""
        return element.text
    
    def is_element_displayed(self, element):
        """Check if element is displayed"""
        return element.is_displayed()
    
    def is_element_enabled(self, element):
        """Check if element is enabled"""
        return element.is_enabled()
