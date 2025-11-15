"""
Debug script - print all text elements on screen after login
"""
import sys, os, time
sys.path.insert(0, '/home/thao/Video_Al_App/appium_test')

from config.test_config import TestConfig
from page_objects.login_page import LoginPage

print('🚀 Starting debug...')

# Restart app
import subprocess
try:
    subprocess.run(["adb", "shell", "am", "force-stop", "com.fau.dmvgenie"],
                   capture_output=True, timeout=5)
    time.sleep(1)
    subprocess.run(["adb", "shell", "am", "start", "-n", "com.fau.dmvgenie/.MainActivity"],
                   capture_output=True, timeout=5)
    time.sleep(3)
except:
    pass

driver = TestConfig.create_android_driver()
driver.implicitly_wait(8)

print('✅ Driver created')

# Login
login_page = LoginPage(driver)
if login_page.is_login_page_displayed():
    print('⏳ Logging in...')
    login_page.login('admin@gmail.com', 'admin123')
    time.sleep(5)
    print('✅ Login complete')

# Print current state
print(f'\n📍 Current activity: {driver.current_activity}')

# Get all text elements
print('\n📋 All text elements on screen:')
all_elements = driver.find_elements("xpath", "//*[@text]")
print(f'Total elements with text: {len(all_elements)}')

texts = []
for i, elem in enumerate(all_elements):
    try:
        text = elem.text
        if text.strip():
            texts.append(text)
            print(f'  {i}: "{text}"')
    except:
        pass

# Also check @text attribute directly
print('\n📋 Text attributes in XML:')
all_with_text_attr = driver.find_elements("xpath", "//*[@text]")
for i, elem in enumerate(all_with_text_attr[:15]):
    try:
        text_attr = elem.get_attribute("text")
        if text_attr:
            print(f'  {i}: text="{text_attr}"')
    except:
        pass

# Get visible buttons
print('\n🔘 All buttons:')
buttons = driver.find_elements("xpath", "//android.widget.Button | //android.widget.ImageButton")
print(f'Total buttons: {len(buttons)}')

for i, btn in enumerate(buttons[:10]):
    try:
        print(f'  {i}: text={btn.text}, displayed={btn.is_displayed()}')
    except:
        pass

# Check for Settings text
print('\n🔍 Looking for "Settings" or "Cài đặt":')
settings_els = driver.find_elements("xpath", "//*[contains(@text, 'Settings') or contains(@text, 'Cài')]")
print(f'Found: {len(settings_els)}')
for el in settings_els:
    try:
        print(f'  - {el.text} (visible: {el.is_displayed()})')
    except:
        pass

# Get page source
print('\n📄 Getting page structure...')
try:
    driver.get_screenshot_as_file('/tmp/screenshot.png')
    print('Screenshot saved to /tmp/screenshot.png')
except:
    pass

driver.quit()
print('\n✅ Debug complete')
