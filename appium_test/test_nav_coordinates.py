"""
Test Navigation - Tap Profile arrow button by coordinates
"""
import sys, os, time
sys.path.insert(0, '/home/thao/Video_Al_App/appium_test')

from config.test_config import TestConfig

print('🚀 Test: Navigate Home → Settings → Profile')
print('='*70)

driver = TestConfig.create_android_driver()
driver.implicitly_wait(8)

try:
    print(f'\n📍 Current activity: {driver.current_activity}')
    
    # Step 1: Tap Settings
    print('\n⏳ Step 1: Tap Settings button')
    settings = driver.find_elements("xpath", "//*[@content-desc='Settings']")
    if settings:
        settings[0].click()
        time.sleep(3)
        print('   ✅ Settings tapped')
    
    # Step 2: Look for Profile section and tap the arrow
    print('\n⏳ Step 2: Tap Profile arrow')
    
    # The arrow is at coordinates [880,444] to [975,538]
    # Use coordinates: center point = (927, 491)
    center_x = 927
    center_y = 491
    
    # Use tap action with coordinates
    from appium.webdriver.common.touch_action import TouchAction
    
    action = TouchAction(driver)
    action.tap(x=center_x, y=center_y).perform()
    print(f'   ✅ Tapped at ({center_x}, {center_y})')
    time.sleep(3)
    
    # Step 3: Verify on Profile page
    print(f'\n📍 Current activity: {driver.current_activity}')
    
    # Check page source for Profile header
    page_source = driver.page_source
    if '@text="Profile"' in page_source or 'Profile' in page_source:
        print('   ✓ Profile found in page')
    
    # Check for Edit button
    if 'Edit' in page_source:
        print('   ✓ Edit button found')
    
    # Get all clickable views
    clickables = driver.find_elements("xpath", "//*[@clickable='true']")
    print(f'   Clickable elements: {len(clickables)}')
    
    # Look for Profile page specific elements
    profile_header = driver.find_elements("xpath", "//*[contains(@content-desc, 'Profile')]")
    if profile_header:
        print(f'   ✅ SUCCESS: Profile page detected!')
        for p in profile_header:
            try:
                desc = p.get_attribute("content-desc")
                if desc:
                    print(f'      - {desc}')
            except:
                pass
    else:
        print('   ❌ Profile header not found')
    
    # Final check
    if 'Edit' in page_source and 'Profile' in page_source:
        print('\n✅ SUCCESS: On Profile page!')
    else:
        print('\n❌ FAILED: Not on Profile page')

except Exception as e:
    print(f'\n❌ Error: {e}')
    import traceback
    traceback.print_exc()

finally:
    driver.quit()
    print('\n✅ Done')
