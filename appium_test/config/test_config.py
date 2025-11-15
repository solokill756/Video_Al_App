"""
Test Configuration
Contains Appium capabilities and driver setup
"""
from appium import webdriver
from appium.options.android import UiAutomator2Options
import os


class TestConfig:
    # Appium Server
    APPIUM_SERVER = "http://127.0.0.1:4723"
    
    # Test Data
    VALID_EMAIL = "admin@gmail.com"
    VALID_PASSWORD = "admin123"
    VALID_NAME = "Test User"
    VALID_PHONE = "0987654321"
    VALID_OTP = "123456"  # This should be obtained from your test backend
    
    # Invalid Test Data
    INVALID_EMAIL = "invalid-email"
    SHORT_PASSWORD = "123"
    WRONG_PASSWORD = "WrongPass123"
    
    # Timeouts
    DEFAULT_TIMEOUT = 30
    SHORT_TIMEOUT = 10
    LONG_TIMEOUT = 60
    
    @staticmethod
    def get_android_capabilities(app_path):
        """Get Android capabilities for Appium"""
        options = UiAutomator2Options()
        options.platform_name = "Android"
        options.platform_version = "13.0"  # Change to your Android version
        options.device_name = "Android Emulator"
        options.automation_name = "UiAutomator2"
        
        # App configuration
        if app_path and os.path.exists(app_path):
            options.app = app_path
        else:
            # If app is already installed, use package and activity
            options.app_package = "com.fau.dmvgenie"  # Your actual package name
            options.app_activity = ".MainActivity"
        
        # Additional capabilities
        options.no_reset = True  # Don't reset app state between tests
        options.full_reset = False
        options.new_command_timeout = 300
        options.auto_grant_permissions = True
        
        return options
    
    @staticmethod
    def get_ios_capabilities(app_path):
        """Get iOS capabilities for Appium"""
        capabilities = {
            'platformName': 'iOS',
            'platformVersion': '16.0',  # Change to your iOS version
            'deviceName': 'iPhone 14',
            'automationName': 'XCUITest',
            'app': app_path,
            'noReset': False,
            'fullReset': False,
            'newCommandTimeout': 300,
            'autoAcceptAlerts': True,
        }
        return capabilities
    
    @staticmethod
    def create_android_driver(app_path=None):
        """Create and return Android driver"""
        options = TestConfig.get_android_capabilities(app_path)
        driver = webdriver.Remote(
            TestConfig.APPIUM_SERVER,
            options=options
        )
        driver.implicitly_wait(TestConfig.DEFAULT_TIMEOUT)
        return driver
    
    @staticmethod
    def create_ios_driver(app_path):
        """Create and return iOS driver"""
        capabilities = TestConfig.get_ios_capabilities(app_path)
        driver = webdriver.Remote(
            TestConfig.APPIUM_SERVER,
            desired_capabilities=capabilities
        )
        driver.implicitly_wait(TestConfig.DEFAULT_TIMEOUT)
        return driver
