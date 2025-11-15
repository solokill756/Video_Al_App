# 🚀 HƯỚNG DẪN CHẠY E2E TESTS - STEP BY STEP

## ✅ Đã Hoàn Thành (Prerequisites)

- ✓ Node.js v22.19.0 (đã cài)
- ✓ npm v10.9.3 (đã cài)
- ✓ Python 3.12.3 (đã cài)
- ✓ Appium 2.0.1 (đã cài)
- ✓ uiautomator2 driver (đã cài)
- ✓ ADB version 1.0.41 (đã cài)
- ✓ Thiết bị Android: RF8R32EP5RY (đã kết nối)
- ✓ Python dependencies (đã cài trong venv)
- ✓ App đã build: app-debug.apk
- ✓ Package name: com.fau.dmvgenie

---

## 📋 CÁCH CHẠY TESTS

### Option 1: Chạy Tất Cả Tests (Tự Động)

#### Bước 1: Mở Terminal 1 - Khởi động Appium Server

```bash
appium
```

**Để terminal này chạy trong nền**

#### Bước 2: Mở Terminal 2 - Chạy Tests

```bash
cd /home/thao/Video_Al_App/appium_test
source venv/bin/activate
cd test_cases
python3 run_all_tests.py
```

---

### Option 2: Chạy Từng Test Suite

#### A. CHỈ CHẠY LOGIN TESTS (8 tests)

**Terminal 1:** (Appium server - đã chạy từ trước)

```bash
appium
```

**Terminal 2:**

```bash
cd /home/thao/Video_Al_App/appium_test
source venv/bin/activate
cd test_cases
python3 test_login.py
```

**Các test sẽ chạy:**

1. test_01_login_page_displayed
2. test_02_login_with_valid_credentials
3. test_03_login_with_invalid_email
4. test_04_login_with_empty_email
5. test_05_login_with_empty_password
6. test_06_login_with_wrong_password
7. test_07_navigate_to_register
8. test_08_navigate_to_forgot_password

---

#### B. CHỈ CHẠY REGISTER TESTS (9 tests)

**Terminal 1:** (Appium server - đã chạy từ trước)

```bash
appium
```

**Terminal 2:**

```bash
cd /home/thao/Video_Al_App/appium_test
source venv/bin/activate
cd test_cases
python3 test_register.py
```

**Các test sẽ chạy:**

1. test_01_register_page_displayed
2. test_02_register_with_valid_email
3. test_03_register_with_invalid_email
4. test_04_register_with_empty_email
5. test_05_complete_registration_flow
6. test_06_register_detail_with_invalid_otp
7. test_07_register_with_password_mismatch
8. test_08_resend_otp
9. test_09_navigate_back_to_login

---

### Option 3: Chạy 1 Test Cụ Thể

**Terminal 1:** (Appium server)

```bash
appium
```

**Terminal 2:**

```bash
cd /home/thao/Video_Al_App/appium_test
source venv/bin/activate
cd test_cases

# Chạy 1 test login cụ thể
python3 test_login.py LoginTests.test_02_login_with_valid_credentials

# Hoặc chạy 1 test register cụ thể
python3 test_register.py RegisterTests.test_05_complete_registration_flow
```

---

### Option 4: Sử Dụng Script Tự Động

```bash
cd /home/thao/Video_Al_App/appium_test
./run_tests.sh
```

**Script sẽ:**

- Kiểm tra Appium server
- Kiểm tra thiết bị Android
- Cho phép chọn test muốn chạy
- Tự động chạy tests

---

## 🔧 COMMANDS QUAN TRỌNG

### Khi Cần Install App Lên Device

```bash
cd /home/thao/Video_Al_App
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

### Khi Cần Uninstall App

```bash
adb uninstall com.fau.dmvgenie
```

### Khi Cần Clear App Data

```bash
adb shell pm clear com.fau.dmvgenie
```

### Kiểm Tra App Đang Chạy

```bash
adb shell dumpsys window | grep mCurrentFocus
```

### Xem Logs Realtime

```bash
adb logcat | grep -i flutter
```

### Stop Appium Server

```bash
# Trong terminal đang chạy Appium, nhấn: Ctrl + C
```

---

## 📊 ĐÁNH GIÁ KẾT QUẢ

### Khi Test Pass

```
✓ test_01_login_page_displayed ... ok
✓ test_02_login_with_valid_credentials ... ok
...
----------------------------------------------------------------------
Ran 8 tests in 245.123s
OK
```

### Khi Test Fail

- Screenshot tự động lưu tại: `appium_test/test_cases/screenshots/`
- Tên file: `login_test_<tên_test>_failed.png`
- Xem log chi tiết để debug

---

## 🐛 TROUBLESHOOTING

### Lỗi: Connection Refused

**Nguyên nhân:** Appium server chưa chạy
**Giải pháp:**

```bash
# Terminal 1
appium
```

### Lỗi: No Devices Connected

**Nguyên nhân:** Thiết bị bị mất kết nối
**Giải pháp:**

```bash
adb kill-server
adb start-server
adb devices
```

### Lỗi: App Not Found

**Nguyên nhân:** App chưa được install hoặc package name sai
**Giải pháp:**

```bash
# Install app
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Hoặc kiểm tra package name trong test_config.py
# Phải là: com.fau.dmvgenie
```

### Lỗi: Element Not Found

**Nguyên nhân:** UI thay đổi hoặc app load chậm
**Giải pháp:**

- Tăng timeout trong `test_config.py`
- Kiểm tra UI bằng Appium Inspector

### Lỗi: Python Module Not Found

**Nguyên nhân:** Quên activate virtual environment
**Giải pháp:**

```bash
cd /home/thao/Video_Al_App/appium_test
source venv/bin/activate
```

---

## 📸 SCREENSHOTS

Khi test fail, screenshots được lưu tự động:

```
appium_test/test_cases/screenshots/
├── login_test_test_02_login_with_valid_credentials_failed.png
├── register_test_test_05_complete_registration_flow_failed.png
└── ...
```

---

## ⚠️ LƯU Ý QUAN TRỌNG

### Test Data

- **Email:** test_user@example.com
- **Password:** Test@123456
- **OTP:** 123456 (cần config backend để trả về OTP này)

### Thời Gian

- Mỗi test: ~30-60 giây
- Toàn bộ suite: ~15-20 phút
- Cần kiên nhẫn, đừng interrupt

### App State

- App sẽ được khởi động lại cho mỗi test
- Data sẽ được reset (no_reset = False)
- Nếu muốn giữ data giữa các test, đổi `no_reset = True` trong test_config.py

---

## 🎯 NEXT STEPS

1. **Chạy test lần đầu để xem app hoạt động**

   ```bash
   cd /home/thao/Video_Al_App/appium_test
   source venv/bin/activate
   cd test_cases
   python3 test_login.py
   ```

2. **Nếu test fail, xem screenshot để debug**

3. **Cập nhật test data trong test_config.py nếu cần**

4. **Chạy toàn bộ test suite**
   ```bash
   python3 run_all_tests.py
   ```

---

**🚀 Sẵn sàng chạy test! Good luck!**
