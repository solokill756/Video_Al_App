"""
Debug: Detailed page inspection to find actual field structure
"""
import sys, os, time
sys.path.insert(0, '/home/thao/Video_Al_App/appium_test')

from config.test_config import TestConfig
from page_objects.login_page import LoginPage
import subprocess

# Restart app
print("🔄 Restarting app...")
subprocess.run(["adb", "shell", "am", "force-stop", "com.fau.dmvgenie"],
               capture_output=True, timeout=5)
time.sleep(2)
subprocess.run(["adb", "shell", "am", "start", "-n", "com.fau.dmvgenie/.MainActivity"],
               capture_output=True, timeout=5)
time.sleep(3)

driver = TestConfig.create_android_driver()
driver.implicitly_wait(8)

try:
    # Login
    print('\n⏳ Login...')
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
    
    print('\n' + '='*70)
    print('PAGE STRUCTURE ANALYSIS - Profile Page (Non-Edit Mode)')
    print('='*70)
    
    # Get current activity
    activity = driver.current_activity
    print(f'\n📍 Current Activity: {activity}')
    
    # Check for Profile header
    profile_headers = driver.find_elements("xpath", "//*[@content-desc='Profile']")
    print(f'\n✅ Profile headers found: {len(profile_headers)}')
    
    # Get page source
    page_source = driver.page_source
    
    # Save full page XML
    with open('/home/thao/Video_Al_App/appium_test/page_dump_full.xml', 'w') as f:
        f.write(page_source)
    print('📄 Full page saved to page_dump_full.xml')
    
    # Look for ALL input field types
    print('\n' + '='*70)
    print('FIELD TYPES FOUND:')
    print('='*70)
    
    # EditText
    edittext = driver.find_elements("class name", "android.widget.EditText")
    print(f'\n1️⃣  android.widget.EditText: {len(edittext)}')
    
    # FrameLayout (sometimes used for Flutter widgets)
    frames = driver.find_elements("class name", "android.widget.FrameLayout")
    print(f'2️⃣  android.widget.FrameLayout: {len(frames)}')
    
    # RelativeLayout
    relative = driver.find_elements("class name", "android.widget.RelativeLayout")
    print(f'3️⃣  android.widget.RelativeLayout: {len(relative)}')
    
    # LinearLayout
    linear = driver.find_elements("class name", "android.widget.LinearLayout")
    print(f'4️⃣  android.widget.LinearLayout: {len(linear)}')
    
    # View
    views = driver.find_elements("class name", "android.view.View")
    print(f'5️⃣  android.view.View: {len(views)}')
    
    # All with content-desc
    all_desc = driver.find_elements("xpath", "//*[@content-desc]")
    print(f'6️⃣  Elements with content-desc: {len(all_desc)}')
    
    print('\n' + '='*70)
    print('ELEMENTS WITH CONTENT-DESC (relevant ones):')
    print('='*70)
    
    for elem in all_desc:
        try:
            desc = elem.get_attribute("content-desc")
            if any(x in desc for x in ['Name', 'Email', 'Phone', 'Edit', 'Save', 'Profile']):
                text = elem.get_attribute("text") or "(no text)"
                tag = elem.tag_name
                bounds = elem.get_attribute("bounds")
                print(f'\n  Tag: {tag}')
                print(f'  content-desc: "{desc}"')
                print(f'  text: "{text}"')
                print(f'  bounds: {bounds}')
        except:
            pass
    
    # Now tap Edit to enter edit mode
    print('\n' + '='*70)
    print('TAPPING EDIT...')
    print('='*70)
    
    edit_buttons = driver.find_elements("xpath", "//*[@content-desc='Edit']")
    if edit_buttons:
        edit_buttons[0].click()
        time.sleep(2)
        print('✅ Edit mode ON')
    
    print('\n' + '='*70)
    print('FIELD TYPES IN EDIT MODE:')
    print('='*70)
    
    # Check again in edit mode
    edittext_edit = driver.find_elements("class name", "android.widget.EditText")
    print(f'\n1️⃣  android.widget.EditText: {len(edittext_edit)}')
    
    for i, field in enumerate(edittext_edit):
        try:
            text = field.text or field.get_attribute("text")
            hint = field.get_attribute("hint")
            enabled = field.get_attribute("enabled")
            print(f'\n  Field {i}:')
            print(f'    text: "{text}"')
            print(f'    hint: "{hint}"')
            print(f'    enabled: {enabled}')
            print(f'    clickable: {field.get_attribute("clickable")}')
            print(f'    focusable: {field.get_attribute("focusable")}')
        except Exception as e:
            print(f'  Field {i}: Error - {e}')
    
    # Check if we can find by content-desc in edit mode
    print('\n' + '='*70)
    print('FIELDS WITH CONTENT-DESC IN EDIT MODE:')
    print('='*70)
    
    field_descs = driver.find_elements("xpath", "//*[@content-desc='Full Name' or @content-desc='Email' or @content-desc='Phone Number']")
    print(f'\nFields found: {len(field_descs)}')
    
    for i, field in enumerate(field_descs):
        try:
            desc = field.get_attribute("content-desc")
            text = field.get_attribute("text")
            tag = field.tag_name
            print(f'\n  Field {i}:')
            print(f'    tag: {tag}')
            print(f'    content-desc: "{desc}"')
            print(f'    text: "{text}"')
        except Exception as e:
            print(f'  Field {i}: Error - {e}')
    
    # Save page in edit mode
    page_edit = driver.page_source
    with open('/home/thao/Video_Al_App/appium_test/page_dump_edit.xml', 'w') as f:
        f.write(page_edit)
    print('\n📄 Edit mode page saved to page_dump_edit.xml')

except Exception as e:
    print(f'\n❌ Error: {e}')
    import traceback
    traceback.print_exc()

finally:
    driver.quit()
    print('\n✅ Done!')
