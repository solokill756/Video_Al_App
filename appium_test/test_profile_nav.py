"""
Simple Profile Navigation Test - starting from HOME page
Assume already logged in on home page
"""
import sys, os, time
sys.path.insert(0, '/home/thao/Video_Al_App/appium_test')

from config.test_config import TestConfig

print('🚀 Test: Navigate Home → Settings → Profile')
print('='*70)

driver = TestConfig.create_android_driver()
driver.implicitly_wait(8)

try:
    # Current state
    print(f'\n📍 Current activity: {driver.current_activity}')
    
    # Get all elements with text
    all_text = driver.find_elements("xpath", "//*[@text]")
    print(f'\n📋 All text on screen ({len(all_text)} elements):')
    for i, el in enumerate(all_text[:20]):
        try:
            # Try both methods
            text = el.text
            if not text:
                text = el.get_attribute("text")
            if text and text.strip():
                print(f'  {i}: "{text}"')
        except:
            pass
    
    # Look for Settings
    print('\n🔍 Step 1: Find Settings button')
    settings = driver.find_elements("xpath", "//*[contains(@text, 'Settings') or contains(@text, 'Cài')]")
    print(f'   Found {len(settings)} elements')
    
    if settings:
        for i, s in enumerate(settings):
            try:
                text = s.text or s.get_attribute("text")
                print(f'   {i}: text="{text}", visible={s.is_displayed()}')
            except:
                pass
        
        # Tap first visible Settings
        for s in settings:
            try:
                if s.is_displayed():
                    print(f'   ✅ Tapping Settings...')
                    s.click()
                    time.sleep(3)
                    print(f'   ✅ Settings tapped')
                    break
            except Exception as e:
                print(f'   Error: {e}')
    else:
        print('   ❌ Settings not found!')
    
    # Check current page
    print(f'\n📍 Current activity after tap: {driver.current_activity}')
    current_text = driver.find_elements("xpath", "//*[@text]")
    print(f'   Text elements now: {len(current_text)}')
    
    # Look for Profile button
    print('\n🔍 Step 2: Find Profile button in Settings')
    profiles = driver.find_elements("xpath", "//*[contains(@text, 'Profile')]")
    print(f'   Found {len(profiles)} Profile elements')
    
    if profiles:
        for i, p in enumerate(profiles):
            try:
                print(f'   {i}: text="{p.text}", visible={p.is_displayed()}')
            except:
                pass
    
    # Look for forward arrow
    print('\n🔍 Step 3: Find forward arrow (arrow_forward_ios)')
    arrows = driver.find_elements("xpath", "//android.widget.ImageView[@content-desc='arrow_forward_ios']")
    print(f'   Found {len(arrows)} arrows')
    
    if arrows:
        for i, arrow in enumerate(arrows[:3]):
            try:
                print(f'   {i}: visible={arrow.is_displayed()}, location={arrow.location}')
            except:
                pass
        
        # Tap first arrow
        try:
            print(f'   ✅ Tapping first arrow...')
            arrows[0].click()
            time.sleep(3)
            print(f'   ✅ Arrow tapped')
        except Exception as e:
            print(f'   Error: {e}')
    else:
        print('   ❌ No forward arrows found!')
    
    # Check if on Profile page
    print(f'\n📍 Final activity: {driver.current_activity}')
    profile_elements = driver.find_elements("xpath", "//*[@text='Profile']")
    print(f'   Profile header: {len(profile_elements)} found')
    
    if profile_elements:
        print('   ✅ SUCCESS: On Profile page!')
    else:
        print('   ❌ NOT on Profile page')
    
    # Get all text on current screen
    print(f'\n📋 Final screen text:')
    final_text = driver.find_elements("xpath", "//*[@text]")
    for i, el in enumerate(final_text[:15]):
        try:
            text = el.text or el.get_attribute("text")
            if text and text.strip():
                print(f'  {i}: "{text}"')
        except:
            pass

except Exception as e:
    print(f'\n❌ Error: {e}')
    import traceback
    traceback.print_exc()

finally:
    driver.quit()
    print('\n✅ Done')
