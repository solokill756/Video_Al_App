"""
Dump page source to understand current state
"""
import sys, os, time
sys.path.insert(0, '/home/thao/Video_Al_App/appium_test')

from config.test_config import TestConfig
import json

print('🚀 Dumping page state...')

driver = TestConfig.create_android_driver()
driver.implicitly_wait(5)

try:
    print(f'Activity: {driver.current_activity}')
    print(f'Package: {driver.current_package}')
    
    # Get page source
    print('\n📄 Getting page source...')
    page_source = driver.page_source
    
    # Save to file
    with open('/tmp/page_source.xml', 'w') as f:
        f.write(page_source)
    
    print('✅ Page source saved to /tmp/page_source.xml')
    
    # Print first 2000 chars
    print('\n📋 First 2000 chars of page source:')
    print(page_source[:2000])
    
    # Count elements
    print(f'\n📊 Page source length: {len(page_source)} chars')
    
    # Look for specific strings
    print('\n🔍 Looking for key strings:')
    if 'Settings' in page_source:
        print('  ✓ "Settings" found')
    if 'Cài' in page_source:
        print('  ✓ "Cài" found')
    if 'Profile' in page_source:
        print('  ✓ "Profile" found')
    if 'Home' in page_source:
        print('  ✓ "Home" found')
    if 'Login' in page_source:
        print('  ✓ "Login" found')
    if 'Email' in page_source:
        print('  ✓ "Email" found')
    if 'Password' in page_source:
        print('  ✓ "Password" found')
    
except Exception as e:
    print(f'Error: {e}')
    import traceback
    traceback.print_exc()

finally:
    driver.quit()
    print('\n✅ Done')
