"""
Debug: Check what elements exist in edit mode
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
    print('⏳ Tapping Edit...')
    edit_buttons = driver.find_elements("xpath", "//*[@content-desc='Edit']")
    print(f'  Edit buttons found: {len(edit_buttons)}')
    if edit_buttons:
        edit_buttons[0].click()
        time.sleep(2)
        print('✅ Edit mode ON')
    
    # Dump page in edit mode
    page_source = driver.page_source
    
    print('\n📋 Elements in EDIT MODE:')
    
    # FIRST: Check for Save button
    print('\n🔍 Looking for Save button...')
    save_buttons = driver.find_elements("xpath", "//*[@content-desc='Save']")
    print(f'  Save buttons (content-desc): {len(save_buttons)}')
    
    # Also try by text
    save_text = driver.find_elements("xpath", "//*[@text='Save']")
    print(f'  Save buttons (text attribute): {len(save_text)}')
    
    # Find all clickable elements
    clickable = driver.find_elements("xpath", "//*[@clickable='true']")
    print(f'\n  All clickable elements: {len(clickable)}')
    
    # Show last 10 clickable
    print('\n  Last 10 clickable elements:')
    for elem in clickable[-10:]:
        try:
            desc = elem.get_attribute("content-desc") or "(no desc)"
            text = elem.get_attribute("text") or "(no text)"
            bounds = elem.get_attribute("bounds")
            print(f'    desc="{desc}", text="{text}", bounds={bounds}')
        except:
            pass
    
    # Find all EditText
    edittext = driver.find_elements("class name", "android.widget.EditText")
    print(f'\nEditText fields: {len(edittext)}')
    for i, et in enumerate(edittext):
        try:
            text = et.text or et.get_attribute("text") or "(empty)"
            hint = et.get_attribute("hint") or "(no hint)"
            enabled = et.get_attribute("enabled")
            print(f'  {i}: text="{text}", hint="{hint}", enabled={enabled}')
        except:
            pass
    
    # Find all Views with content-desc
    print('\nViews with content-desc:')
    views = driver.find_elements("xpath", "//*[@content-desc]")
    for v in views:
        try:
            desc = v.get_attribute("content-desc")
            if desc and any(x in desc for x in ['Full', 'Email', 'Phone', 'Name', 'Save', 'Edit']):
                text = v.get_attribute("text") or "(no text)"
                print(f'  - desc="{desc}", text="{text}"')
        except:
            pass
    
    # Save page source
    with open('/home/thao/Video_Al_App/appium_test/edit_mode_dump.xml', 'w') as f:
        f.write(page_source)
    
    print('\n✅ Saved to edit_mode_dump.xml')
    
    # Try to interact with first EditText
    if edittext:
        print(f'\n⏳ Trying to type in first EditText...')
        try:
            edittext[0].click()
            time.sleep(0.5)
            edittext[0].send_keys("TEST")
            time.sleep(0.5)
            new_val = edittext[0].text
            print(f'   Value after send_keys: "{new_val}"')
        except Exception as e:
            print(f'   Error: {e}')
    
    # Try to tap Save button if found
    if save_buttons:
        print(f'\n⏳ Trying to tap Save button...')
        try:
            save_buttons[0].click()
            time.sleep(2)
            print(f'   ✅ Clicked Save')
        except Exception as e:
            print(f'   Error clicking Save: {e}')

except Exception as e:
    print(f'Error: {e}')
    import traceback
    traceback.print_exc()

finally:
    driver.quit()
