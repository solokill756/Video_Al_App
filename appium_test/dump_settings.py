"""
Dump page source when on Settings page
"""
import sys, os, time
sys.path.insert(0, '/home/thao/Video_Al_App/appium_test')

from config.test_config import TestConfig

print('🚀 Dump Settings page...')

driver = TestConfig.create_android_driver()
driver.implicitly_wait(5)

try:
    # Tap Settings
    settings = driver.find_elements("xpath", "//*[@content-desc='Settings']")
    if settings:
        settings[0].click()
        time.sleep(3)
    
    # Dump page source
    page_source = driver.page_source
    
    # Find where "Profile" appears
    lines = page_source.split('\n')
    for i, line in enumerate(lines):
        if 'Profile' in line or 'arrow' in line or 'arrow_forward' in line:
            # Print context
            start = max(0, i-2)
            end = min(len(lines), i+3)
            for j in range(start, end):
                marker = ">>> " if j == i else "    "
                print(f"{marker}{lines[j]}")
            print()
    
    # Save full source
    with open('/home/thao/Video_Al_App/appium_test/settings_page.xml', 'w') as f:
        f.write(page_source)
    
    print('\n✅ Settings page source saved to settings_page.xml')

except Exception as e:
    print(f'Error: {e}')
    import traceback
    traceback.print_exc()

finally:
    driver.quit()
