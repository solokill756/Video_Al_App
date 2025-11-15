"""
Debug Script - Check App Navigation Structure
"""
import sys
import os
import time

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config.test_config import TestConfig
from page_objects.login_page import LoginPage

# Create driver
driver = TestConfig.create_android_driver()
login_page = LoginPage(driver)

print("\n=== DEBUGGING APP STRUCTURE ===\n")

try:
    # Login
    print("1️⃣  Logging in...")
    if login_page.is_login_page_displayed():
        login_page.login(TestConfig.VALID_EMAIL, TestConfig.VALID_PASSWORD)
        time.sleep(3)
    
    print("✅ Logged in successfully")
    
    # Get page source to see structure
    print("\n2️⃣  Checking bottom navigation bar...")
    
    # Find all buttons in bottom nav area
    try:
        bottom_nav_elements = driver.find_elements("xpath", 
            "//android.widget.FrameLayout[@resource-id and contains(@resource-id, 'bottom')]")
        print(f"   Found {len(bottom_nav_elements)} bottom nav elements")
        
        # Try to find all clickable items
        clickable_items = driver.find_elements("xpath", 
            "//android.widget.FrameLayout | //android.widget.LinearLayout | //android.widget.Button")
        
        print(f"   Total clickable items found: {len(clickable_items)}")
        
        # Try to find text items
        text_elements = driver.find_elements("xpath", "//*[@text]")
        print(f"\n   Text elements on screen:")
        for i, elem in enumerate(text_elements[:20]):  # Show first 20
            try:
                text = elem.text
                if text and len(text) > 0:
                    print(f"     [{i}] {text}")
            except:
                pass
    except Exception as e:
        print(f"   Error scanning elements: {str(e)}")
    
    # Try to find Settings specifically
    print("\n3️⃣  Looking for Settings...")
    try:
        # Search for "Cài đặt" (Vietnamese for Settings)
        settings_elements = driver.find_elements("xpath", "//*[contains(@text, 'Cài') or contains(@text, 'cài') or contains(@text, 'Settings') or contains(@text, 'settings')]")
        print(f"   Found {len(settings_elements)} Settings-related elements")
        
        for i, elem in enumerate(settings_elements):
            try:
                print(f"     [{i}] Text: '{elem.text}' | Resource ID: {elem.get_attribute('resource-id')}")
            except:
                pass
    except Exception as e:
        print(f"   Error finding settings: {str(e)}")
    
    # Try to find all FrameLayout with icons
    print("\n4️⃣  Looking for tab bar items...")
    try:
        tab_items = driver.find_elements("xpath", "//android.widget.FrameLayout[@resource-id]")
        print(f"   Found {len(tab_items)} FrameLayout elements")
        
        for i, item in enumerate(tab_items[:10]):
            try:
                resource_id = item.get_attribute('resource-id')
                if 'bottom' in resource_id or 'nav' in resource_id or 'tab' in resource_id.lower():
                    print(f"     [{i}] Resource ID: {resource_id}")
            except:
                pass
    except Exception as e:
        print(f"   Error finding tabs: {str(e)}")
    
    # Get page source (XML dump)
    print("\n5️⃣  Page hierarchy (first 2000 chars):")
    print("=" * 50)
    page_source = driver.page_source
    print(page_source[:2000])
    print("\n" + "=" * 50)
    
    print("\n✅ Debug complete - check output above")

except Exception as e:
    print(f"\n❌ Error during debug: {str(e)}")
    import traceback
    traceback.print_exc()

finally:
    driver.quit()
    print("\n✅ Driver closed")
