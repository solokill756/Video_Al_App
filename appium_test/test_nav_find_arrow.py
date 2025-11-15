"""
Test Navigation - Find and tap the Profile arrow element
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
    
    # Step 2: Find and tap the Profile section arrow
    print('\n⏳ Step 2: Find and tap Profile arrow')
    
    # In the XML, the arrow is a clickable View at bounds [880,444][975,538]
    # It's the 5th element (index 4) in the ScrollView
    # Strategy: Find all clickable Views in Settings and tap the right one
    
    # First, find all clickable android.view.View elements
    clickable_views = driver.find_elements("xpath", "//android.view.View[@clickable='true']")
    print(f'   Found {len(clickable_views)} clickable views')
    
    # Look for the one in the right position (should be narrow arrow icon)
    arrow_found = False
    for i, view in enumerate(clickable_views):
        try:
            bounds = view.get_attribute("bounds")
            # Arrow bounds: [880,444][975,538]
            if bounds and '880' in bounds and '444' in bounds:
                print(f'   Found arrow at bounds: {bounds}')
                view.click()
                print(f'   ✅ Arrow clicked!')
                time.sleep(3)
                arrow_found = True
                break
        except Exception as e:
            pass
    
    if not arrow_found:
        print('   ⚠️  Arrow not found by bounds, trying by position...')
        # Try clicking on the last clickable view in the profile card area
        # (Usually the Profile section is around Y=400-550, X=800+)
        for i, view in enumerate(clickable_views):
            try:
                bounds = view.get_attribute("bounds")
                # Parse bounds format: [left,top][right,bottom]
                if bounds:
                    import re
                    match = re.search(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]', bounds)
                    if match:
                        left, top, right, bottom = map(int, match.groups())
                        # Arrow should be on right side, narrow, in upper-middle area
                        width = right - left
                        if width < 150 and width > 50 and left > 800 and top > 300 and top < 700:
                            print(f'   Found possible arrow at bounds: {bounds}')
                            view.click()
                            print(f'   ✅ Clicked!')
                            time.sleep(3)
                            arrow_found = True
                            break
            except:
                pass
    
    # Step 3: Verify on Profile page
    print(f'\n📍 Current activity: {driver.current_activity}')
    
    page_source = driver.page_source
    
    # Get page info
    views_on_page = driver.find_elements("xpath", "//*[@content-desc]")
    print(f'   Elements with content-desc: {len(views_on_page)}')
    
    # Check for Profile page indicators
    found_profile_indicators = False
    for v in views_on_page:
        try:
            desc = v.get_attribute("content-desc")
            if desc and ('Profile' in desc or 'Full Name' in desc or 'Personal' in desc):
                print(f'   ✓ Found: {desc}')
                found_profile_indicators = True
        except:
            pass
    
    if found_profile_indicators or ('Personal' in page_source and 'Email' in page_source):
        print('\n✅ SUCCESS: On Profile page!')
    else:
        print('\n❌ FAILED: Not on Profile page')
        print(f'   Page contains: {", ".join([w for w in ["Profile", "Edit", "Email", "Phone"] if w in page_source])}')

except Exception as e:
    print(f'\n❌ Error: {e}')
    import traceback
    traceback.print_exc()

finally:
    driver.quit()
    print('\n✅ Done')
