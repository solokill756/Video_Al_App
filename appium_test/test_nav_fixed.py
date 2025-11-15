"""
Test Navigation - Using correct locators (content-desc for Flutter)
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
    
    # Step 1: Tap Settings (using content-desc)
    print('\n⏳ Step 1: Tap Settings button')
    settings = driver.find_elements("xpath", "//*[@content-desc='Settings']")
    print(f'   Found {len(settings)} Settings elements')
    
    if settings:
        settings[0].click()
        time.sleep(3)
        print('   ✅ Settings tapped')
    else:
        print('   ❌ Settings not found!')
    
    # Step 2: Check if on Settings page
    print(f'\n📍 Current activity: {driver.current_activity}')
    
    # Get page source to find Profile button
    page_source = driver.page_source
    
    # Look for "Profile" in page
    if 'Profile' in page_source:
        print('   ✓ "Profile" text found in page')
    
    # List all android.view.View elements
    views = driver.find_elements("xpath", "//android.view.View[@content-desc]")
    print(f'\n   Views with content-desc: {len(views)}')
    for i, v in enumerate(views[:20]):
        try:
            desc = v.get_attribute("content-desc")
            if desc:
                print(f'   {i}: "{desc}"')
        except:
            pass
    
    # Step 3: Tap the arrow that leads to Profile
    print('\n⏳ Step 2: Find and tap Profile section')
    
    # In Settings, look for the section that goes to Profile
    # Method 1: Look for arrow button (index 4 in the page - first arrow should be Profile)
    arrows = driver.find_elements("xpath", "//android.widget.ImageView[@content-desc='arrow_forward_ios']")
    print(f'   Found {len(arrows)} forward arrows')
    
    if arrows:
        try:
            arrows[0].click()
            time.sleep(3)
            print('   ✅ Arrow tapped')
        except Exception as e:
            print(f'   ❌ Error tapping arrow: {e}')
    
    # Final check
    print(f'\n📍 Final activity: {driver.current_activity}')
    
    # Check for Profile header
    profile_header = driver.find_elements("xpath", "//*[@text='Profile']")
    if profile_header:
        print('   ✅ SUCCESS: On Profile page!')
    else:
        print('   ❌ NOT on Profile page')
    
    # Get final page source
    final_source = driver.page_source
    if 'Profile' in final_source and 'Edit' in final_source:
        print('   ✓ Profile and Edit button found in page')

except Exception as e:
    print(f'\n❌ Error: {e}')
    import traceback
    traceback.print_exc()

finally:
    driver.quit()
    print('\n✅ Done')
