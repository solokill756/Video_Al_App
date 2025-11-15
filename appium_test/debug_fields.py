#!/usr/bin/env python3
"""
Debug script to find input fields
"""
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config.test_config import TestConfig
import time

print("\n🔍 Starting debug session...")
driver = TestConfig.create_android_driver()
time.sleep(3)

print("\n1️⃣ Looking for ALL EditText elements...")
elements = driver.find_elements("class name", "android.widget.EditText")
print(f"   Found {len(elements)} EditText elements")

for i, elem in enumerate(elements):
    try:
        print(f"\n   EditText #{i+1}:")
        print(f"      - text: {elem.text}")
        print(f"      - enabled: {elem.is_enabled()}")
        print(f"      - displayed: {elem.is_displayed()}")
        try:
            desc = elem.get_attribute("content-desc")
            print(f"      - content-desc: {desc}")
        except:
            print(f"      - content-desc: N/A")
        try:
            hint = elem.get_attribute("hint")
            print(f"      - hint: {hint}")
        except:
            print(f"      - hint: N/A")
    except Exception as e:
        print(f"      - Error getting info: {e}")

print("\n2️⃣ Trying to click and type in first EditText...")
if elements:
    try:
        elem = elements[0]
        print(f"   Clicking on element...")
        elem.click()
        time.sleep(1)
        
        print(f"   Typing 'test@example.com'...")
        elem.send_keys("test@example.com")
        time.sleep(2)
        
        print(f"   ✅ Success! Text entered.")
    except Exception as e:
        print(f"   ❌ Failed: {e}")

print("\n3️⃣ Taking screenshot...")
driver.save_screenshot("/tmp/debug_screenshot.png")
print("   Screenshot saved to /tmp/debug_screenshot.png")

print("\n4️⃣ Keeping app open for 10 seconds...")
time.sleep(10)

driver.quit()
print("\n✅ Debug complete!")
