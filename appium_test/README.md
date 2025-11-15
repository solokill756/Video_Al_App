# Hướng Dẫn Chạy E2E Tests với Appium

## 📋 Mục Lục

- [Giới Thiệu](#giới-thiệu)
- [Yêu Cầu Hệ Thống](#yêu-cầu-hệ-thống)
- [Cài Đặt](#cài-đặt)
- [Cấu Hình](#cấu-hình)
- [Chạy Tests](#chạy-tests)
- [Cấu Trúc Dự Án](#cấu-trúc-dự-án)
- [Test Cases](#test-cases)
- [Troubleshooting](#troubleshooting)

## 🎯 Giới Thiệu

Dự án này sử dụng **Appium** để thực hiện E2E (End-to-End) testing cho phần **Login** và **Register** của Flutter app VideoAI.

### Công Nghệ Sử Dụng:

- **Appium**: Framework automation testing cho mobile
- **Python**: Ngôn ngữ lập trình cho test scripts
- **unittest**: Framework testing của Python
- **Page Object Model (POM)**: Design pattern để tổ chức code test

## 💻 Yêu Cầu Hệ Thống

### 1. Node.js & npm

```bash
# Kiểm tra version
node --version  # >= v16.0.0
npm --version   # >= 8.0.0
```

### 2. Appium

```bash
# Cài đặt Appium
npm install -g appium@next

# Kiểm tra version
appium --version  # >= 2.0.0

# Cài đặt driver cho Android
appium driver install uiautomator2
```

### 3. Android SDK & Tools

- Android Studio với SDK đã cài đặt
- Android SDK Platform-tools
- Android Emulator hoặc thiết bị thật

```bash
# Kiểm tra adb
adb version
```

### 4. Python

```bash
# Python 3.8 trở lên
python3 --version  # >= 3.8.0
```

### 5. Java JDK

```bash
# Java Development Kit
java -version  # >= JDK 8
```

## 🔧 Cài Đặt

### Bước 1: Setup Biến Môi Trường

Thêm vào `~/.bashrc` hoặc `~/.zshrc`:

```bash
# Android SDK
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Java
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64  # Điều chỉnh theo hệ thống của bạn
export PATH=$PATH:$JAVA_HOME/bin
```

Reload terminal:

```bash
source ~/.bashrc  # hoặc source ~/.zshrc
```

### Bước 2: Cài Đặt Python Dependencies

```bash
cd appium_test
pip3 install -r requirements.txt
```

### Bước 3: Build Flutter App

#### Cho Android:

```bash
cd /home/thao/Video_Al_App
flutter build apk --debug
```

APK sẽ được tạo tại: `build/app/outputs/flutter-apk/app-debug.apk`

#### Cho Release (optional):

```bash
flutter build apk --release
```

### Bước 4: Khởi Động Appium Server

Mở terminal mới và chạy:

```bash
appium
```

Appium server sẽ chạy tại: `http://127.0.0.1:4723`

## ⚙️ Cấu Hình

### 1. Cấu Hình Test Data

Edit file `appium_test/config/test_config.py`:

```python
# Cập nhật thông tin test
VALID_EMAIL = "your_test_email@example.com"
VALID_PASSWORD = "YourPassword123!"
VALID_NAME = "Your Name"
VALID_PHONE = "0987654321"

# Cập nhật app package
options.app_package = "com.example.dmvgenie"  # Thay bằng package thực của bạn
```

### 2. Kiểm Tra Package Name

```bash
# Cách 1: Từ AndroidManifest.xml
cat android/app/src/main/AndroidManifest.xml | grep package

# Cách 2: Từ build.gradle
cat android/app/build.gradle | grep applicationId
```

### 3. Khởi Động Android Emulator

```bash
# List emulators
emulator -list-avds

# Khởi động emulator
emulator -avd <your_emulator_name> &

# Hoặc dùng thiết bị thật qua USB với USB debugging enabled
adb devices
```

## 🚀 Chạy Tests

### Chạy Tất Cả Tests

```bash
cd appium_test/test_cases
python3 run_all_tests.py
```

### Chạy Từng Test Suite

#### Login Tests:

```bash
python3 test_login.py
```

#### Register Tests:

```bash
python3 test_register.py
```

### Chạy Test Cụ Thể

```bash
# Chạy 1 test method cụ thể
python3 test_login.py LoginTests.test_01_login_page_displayed
```

### Chạy với Pytest (Optional)

```bash
# Cài pytest nếu chưa có
pip3 install pytest pytest-html

# Chạy tests với pytest
pytest test_login.py -v
pytest test_register.py -v

# Tạo HTML report
pytest test_login.py --html=report.html
```

## 📁 Cấu Trúc Dự Án

```
appium_test/
├── config/
│   ├── __init__.py
│   ├── test_config.py          # Cấu hình Appium và test data
│   ├── appium_config.dart      # Config cho Dart (reference)
│   └── test_constants.dart     # Constants cho Dart (reference)
│
├── page_objects/               # Page Object Model
│   ├── __init__.py
│   ├── base_page.py           # Base class với common methods
│   ├── login_page.py          # Login page elements & actions
│   ├── register_page.py       # Register page elements & actions
│   └── register_detail_page.py # Register detail page
│
├── test_cases/                 # Test scripts
│   ├── test_login.py          # Login test cases (8 tests)
│   ├── test_register.py       # Register test cases (9 tests)
│   └── run_all_tests.py       # Run all tests
│
├── helpers/                    # Helper utilities
│   └── appium_helper.dart     # Helper functions (reference)
│
├── screenshots/                # Screenshots của failed tests (auto-generated)
│
└── requirements.txt           # Python dependencies
```

## 🧪 Test Cases

### Login Tests (test_login.py)

| Test                                   | Mô Tả                        | Expected Result             |
| -------------------------------------- | ---------------------------- | --------------------------- |
| `test_01_login_page_displayed`         | Kiểm tra Login page hiển thị | Login page được hiển thị    |
| `test_02_login_with_valid_credentials` | Login với thông tin hợp lệ   | Login thành công            |
| `test_03_login_with_invalid_email`     | Login với email không hợp lệ | Hiển thị lỗi validation     |
| `test_04_login_with_empty_email`       | Login với email trống        | Hiển thị lỗi required       |
| `test_05_login_with_empty_password`    | Login với password trống     | Hiển thị lỗi required       |
| `test_06_login_with_wrong_password`    | Login với password sai       | Hiển thị lỗi authentication |
| `test_07_navigate_to_register`         | Chuyển đến trang Register    | Navigate thành công         |
| `test_08_navigate_to_forgot_password`  | Chuyển đến Forgot Password   | Navigate thành công         |

### Register Tests (test_register.py)

| Test                                       | Mô Tả                           | Expected Result             |
| ------------------------------------------ | ------------------------------- | --------------------------- |
| `test_01_register_page_displayed`          | Kiểm tra Register page hiển thị | Register page được hiển thị |
| `test_02_register_with_valid_email`        | Nhập email hợp lệ và continue   | Navigate đến detail page    |
| `test_03_register_with_invalid_email`      | Nhập email không hợp lệ         | Hiển thị lỗi validation     |
| `test_04_register_with_empty_email`        | Nhập email trống                | Hiển thị lỗi required       |
| `test_05_complete_registration_flow`       | Hoàn thành toàn bộ đăng ký      | Đăng ký thành công          |
| `test_06_register_detail_with_invalid_otp` | Nhập OTP không hợp lệ           | Hiển thị lỗi OTP            |
| `test_07_register_with_password_mismatch`  | Password không khớp             | Hiển thị lỗi mismatch       |
| `test_08_resend_otp`                       | Test chức năng gửi lại OTP      | OTP được gửi lại            |
| `test_09_navigate_back_to_login`           | Quay lại trang Login            | Navigate thành công         |

## 🔍 Troubleshooting

### 1. Appium Server Không Kết Nối Được

```bash
# Kiểm tra Appium server đang chạy
curl http://127.0.0.1:4723/status

# Nếu không chạy, start lại Appium
appium --log-level debug
```

### 2. ADB Không Nhận Thiết Bị

```bash
# Kill và restart adb server
adb kill-server
adb start-server
adb devices
```

### 3. App Không Install Được

```bash
# Uninstall app cũ
adb uninstall com.example.dmvgenie

# Install manual
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

### 4. Element Không Tìm Thấy

- Tăng timeout trong `test_config.py`
- Kiểm tra app UI hierarchy bằng Appium Inspector
- Chạy test với mode debug để xem logs chi tiết

```bash
# Chạy với verbose logging
python3 test_login.py -v
```

### 5. Appium Inspector Setup

```bash
# Cài đặt Appium Inspector
npm install -g appium-inspector

# Hoặc download từ: https://github.com/appium/appium-inspector/releases
```

### 6. Screenshot Của Failed Tests

Khi test fail, screenshot tự động được lưu tại:

```
appium_test/screenshots/
```

## 📝 Ghi Chú Quan Trọng

### 1. Test Data

- **OTP Code**: Trong môi trường test, bạn cần có cách lấy OTP. Có thể:
  - Sử dụng test OTP cố định từ backend
  - Mock API để trả về OTP cố định
  - Sử dụng test user có OTP bypass

### 2. Thời Gian Chạy Test

- Mỗi test case mất khoảng 30-60 giây
- Toàn bộ test suite: ~15-20 phút
- Có thể chạy parallel bằng pytest-xdist

### 3. Clean Test Data

Sau mỗi lần chạy test, có thể cần:

- Xóa user test từ database
- Reset app state
- Clear app data: `adb shell pm clear com.example.dmvgenie`

### 4. CI/CD Integration

Có thể tích hợp vào CI/CD pipeline (Jenkins, GitHub Actions, etc.):

```yaml
# Example GitHub Actions
- name: Run Appium Tests
  run: |
    appium &
    sleep 10
    cd appium_test/test_cases
    python3 run_all_tests.py
```

## 🎯 Best Practices

1. **Page Object Pattern**: Luôn sử dụng POM để dễ maintain
2. **Wait Strategies**: Sử dụng explicit waits thay vì hard-coded sleeps
3. **Test Independence**: Mỗi test phải độc lập, không phụ thuộc test khác
4. **Clear Test Names**: Đặt tên test rõ ràng, mô tả đầy đủ
5. **Screenshot on Failure**: Tự động capture screenshot khi test fail
6. **Logging**: Log đầy đủ để dễ debug

## 📞 Hỗ Trợ

Nếu gặp vấn đề, hãy:

1. Kiểm tra logs của Appium server
2. Xem screenshot của failed tests
3. Chạy test ở debug mode
4. Kiểm tra UI hierarchy bằng Appium Inspector

---

**Chúc bạn testing thành công! 🚀**
