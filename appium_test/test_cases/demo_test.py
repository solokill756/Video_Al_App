"""
Simple Demo Test - Kiểm tra kết nối Appium
"""
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config.test_config import TestConfig

print("=" * 60)
print("🧪 DEMO: Kiểm tra kết nối Appium với thiết bị")
print("=" * 60)

try:
    print("\n📱 Đang kết nối với thiết bị Android...")
    print(f"📍 Appium Server: {TestConfig.APPIUM_SERVER}")
    print(f"📦 Package: com.fau.dmvgenie")
    print(f"⏱️  Timeout: {TestConfig.DEFAULT_TIMEOUT}s")
    
    print("\n🔄 Đang khởi tạo driver...")
    driver = TestConfig.create_android_driver()
    
    print("✅ Kết nối thành công!")
    print("\n📊 Thông tin driver:")
    print(f"   - Session ID: {driver.session_id}")
    print(f"   - Platform: {driver.capabilities.get('platformName')}")
    print(f"   - Device: {driver.capabilities.get('deviceName')}")
    
    print("\n⏳ Chờ 3 giây để app khởi động...")
    import time
    time.sleep(3)
    
    print("\n📸 Chụp screenshot...")
    screenshot_path = "demo_screenshot.png"
    driver.save_screenshot(screenshot_path)
    print(f"✅ Screenshot saved: {screenshot_path}")
    
    print("\n🧹 Đóng driver...")
    driver.quit()
    
    print("\n" + "=" * 60)
    print("✅ DEMO HOÀN TẤT - Kết nối Appium hoạt động tốt!")
    print("=" * 60)
    print("\n👉 Bây giờ bạn có thể chạy test thật:")
    print("   python3 test_login.py")
    print("   hoặc")
    print("   python3 test_register.py")
    print()
    
except Exception as e:
    print(f"\n❌ LỖI: {str(e)}")
    print("\n🔍 Kiểm tra:")
    print("   1. Appium server có đang chạy không?")
    print("   2. Thiết bị có kết nối không? (adb devices)")
    print("   3. App có được install không?")
    sys.exit(1)
