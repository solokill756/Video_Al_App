"""
Debug: Investigate why send_keys() doesn't work on phone field
"""
import sys, os, time
sys.path.insert(0, '/home/thao/Video_Al_App/appium_test')

from config.test_config import TestConfig
from page_objects.login_page import LoginPage
import subprocess

# Restart app
subprocess.run(["adb", "shell", "am", "force-stop", "com.fau.dmvgenie"],
               capture_output=True, timeout=5)
time.sleep(1)
subprocess.run(["adb", "shell", "am", "start", "-n", "com.fau.dmvgenie/.MainActivity"],
               capture_output=True, timeout=5)
time.sleep(3)

driver = TestConfig.create_android_driver()
driver.implicitly_wait(8)

try:
    # Login
    print('⏳ Login...')
    login_page = LoginPage(driver)
    if login_page.is_login_page_displayed():
        login_page.login('admin@gmail.com', 'admin123')
        time.sleep(5)
        print('✅ Logged in')
    
    # Navigate to Settings
    print('\n⏳ Settings...')
    settings = driver.find_elements("xpath", "//*[@content-desc='Settings']")
    if settings:
        settings[0].click()
        time.sleep(3)
    
    # Navigate to Profile
    print('⏳ Profile...')
    clickable_views = driver.find_elements("xpath", "//android.view.View[@clickable='true']")
    for view in clickable_views:
        bounds = view.get_attribute("bounds")
        if bounds and '880' in bounds:
            view.click()
            time.sleep(3)
            break
    
    # TAP EDIT
    print('\n⏳ Tap Edit...')
    edit_buttons = driver.find_elements("xpath", "//*[@content-desc='Edit']")
    if edit_buttons:
        edit_buttons[0].click()
        time.sleep(2)
        print('✅ Edit mode ON')
    
    # Get all EditText and check their properties
    print('\n📋 ALL EDITTEXT FIELDS:')
    edittext_all = driver.find_elements("class name", "android.widget.EditText")
    print(f'Total EditText: {len(edittext_all)}\n')
    
    for i, field in enumerate(edittext_all):
        try:
            text = field.text or field.get_attribute("text") or "(empty)"
            hint = field.get_attribute("hint") or "(no hint)"
            enabled = field.get_attribute("enabled")
            focusable = field.get_attribute("focusable")
            resource_id = field.get_attribute("resource-id")
            
            print(f'Field {i}:')
            print(f'  text: "{text}"')
            print(f'  hint: "{hint}"')
            print(f'  enabled: {enabled}')
            print(f'  focusable: {focusable}')
            print(f'  resource-id: {resource_id}')
            print()
        except Exception as e:
            print(f'Field {i}: Error - {e}\n')
    
    # Now try to interact with PHONE field (usually the last one)
    print('\n⏳ Testing PHONE field interaction...')
    
    if len(edittext_all) >= 2:
        # Phone is usually the last field
        phone_field = edittext_all[-1]
        
        print(f'Phone field current value: "{phone_field.text}"')
        
        # METHOD 1: Clear then send_keys
        print('\nMethod 1: clear() then send_keys()')
        phone_field.clear()
        time.sleep(0.5)
        phone_field.send_keys("1234567890")
        time.sleep(0.5)
        value_after = phone_field.text
        print(f'  Value after send_keys: "{value_after}"')
        print(f'  Success: {value_after == "1234567890"}')
        
        # METHOD 2: Try with triple-tap to select all
        print('\nMethod 2: Triple-tap then send_keys')
        phone_field.clear()
        time.sleep(0.3)
        
        # Get field location and triple-tap
        location = phone_field.location
        size = phone_field.size
        center_x = location['x'] + size['width'] / 2
        center_y = location['y'] + size['height'] / 2
        
        from appium.webdriver.common.touch_action import TouchAction
        action = TouchAction(driver)
        action.tap(x=center_x, y=center_y).tap(x=center_x, y=center_y).tap(x=center_x, y=center_y).perform()
        time.sleep(0.3)
        
        phone_field.send_keys("9876543210")
        time.sleep(0.5)
        value_after_2 = phone_field.text
        print(f'  Value after triple-tap + send_keys: "{value_after_2}"')
        print(f'  Success: {value_after_2 == "9876543210"}')
        
        # METHOD 3: Use set_value if available
        print('\nMethod 3: Direct text replacement via XML')
        phone_field.clear()
        time.sleep(0.3)
        
        # Click to focus
        phone_field.click()
        time.sleep(0.3)
        
        # Use keyboard action
        driver.execute_script("mobile: type", {
            "text": "5555555555"
        })
        time.sleep(0.5)
        value_after_3 = phone_field.text
        print(f'  Value after mobile:type: "{value_after_3}"')
        print(f'  Success: {value_after_3 == "5555555555"}')

except Exception as e:
    print(f'Error: {e}')
    import traceback
    traceback.print_exc()

finally:
    driver.quit()
