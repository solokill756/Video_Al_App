"""
Debug: Navigate to Profile and dump page
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
    print('\n⏳ Tap Settings...')
    settings = driver.find_elements("xpath", "//*[@content-desc='Settings']")
    if settings:
        settings[0].click()
        time.sleep(3)
        print('✅ Settings tapped')
    
    # Tap Profile arrow
    print('\n⏳ Tap Profile arrow...')
    clickable_views = driver.find_elements("xpath", "//android.view.View[@clickable='true']")
    for view in clickable_views:
        bounds = view.get_attribute("bounds")
        if bounds and '880' in bounds:
            view.click()
            time.sleep(3)
            print('✅ Arrow tapped')
            break
    
    # Dump page
    print('\n📄 Dumping Profile page...')
    page_source = driver.page_source
    
    # Look for Profile-related strings
    print('\n🔍 Searching for Profile indicators:')
    for keyword in ['Profile', 'Edit', 'Save', 'Personal', 'Full Name', 'Email', 'Phone']:
        if keyword in page_source:
            print(f'  ✓ "{keyword}" found')
        else:
            print(f'  ✗ "{keyword}" NOT found')
    
    # Get all elements with content-desc
    print('\n📋 All content-desc attributes:')
    views = driver.find_elements("xpath", "//*[@content-desc]")
    descs = []
    for v in views:
        try:
            desc = v.get_attribute("content-desc")
            if desc and desc not in descs:
                descs.append(desc)
                print(f'  - "{desc}"')
        except:
            pass
    
    # Save page source
    with open('/home/thao/Video_Al_App/appium_test/profile_page_dump.xml', 'w') as f:
        f.write(page_source)
    
    print('\n✅ Page saved to profile_page_dump.xml')

except Exception as e:
    print(f'Error: {e}')
    import traceback
    traceback.print_exc()

finally:
    driver.quit()
