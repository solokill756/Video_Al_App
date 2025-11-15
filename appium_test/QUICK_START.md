# Appium E2E Tests - Quick Reference

## 🚀 Quick Start

### 1. Start Appium Server

```bash
appium
```

### 2. Start Android Emulator

```bash
emulator -avd Pixel_5_API_33 &
```

### 3. Run Tests

```bash
./appium_test/run_tests.sh
```

## 📝 Test Commands

### Run All Tests

```bash
cd appium_test/test_cases
python3 run_all_tests.py
```

### Run Login Tests

```bash
python3 test_login.py
```

### Run Register Tests

```bash
python3 test_register.py
```

### Run Specific Test

```bash
python3 test_login.py LoginTests.test_02_login_with_valid_credentials
```

## 🔧 Common Commands

### Check Appium Server

```bash
curl http://127.0.0.1:4723/status
```

### Check Connected Devices

```bash
adb devices
```

### Install App Manually

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

### Uninstall App

```bash
adb uninstall com.example.dmvgenie
```

### Clear App Data

```bash
adb shell pm clear com.example.dmvgenie
```

### View Logcat

```bash
adb logcat | grep -i flutter
```

## 📊 Test Coverage

### Login Tests (8 tests)

- ✅ Login page display
- ✅ Valid credentials login
- ✅ Invalid email validation
- ✅ Empty email validation
- ✅ Empty password validation
- ✅ Wrong password handling
- ✅ Navigate to register
- ✅ Navigate to forgot password

### Register Tests (9 tests)

- ✅ Register page display
- ✅ Valid email entry
- ✅ Invalid email validation
- ✅ Empty email validation
- ✅ Complete registration flow
- ✅ Invalid OTP handling
- ✅ Password mismatch validation
- ✅ Resend OTP functionality
- ✅ Navigate back to login

## 🐛 Troubleshooting Quick Fixes

### Appium Not Running

```bash
killall node
appium
```

### ADB Issues

```bash
adb kill-server
adb start-server
```

### Python Package Issues

```bash
pip3 install --upgrade -r appium_test/requirements.txt
```

### Clean Build

```bash
flutter clean
flutter pub get
flutter build apk --debug
```

## 📁 Important Files

| File               | Purpose                            |
| ------------------ | ---------------------------------- |
| `test_config.py`   | Test configuration and credentials |
| `test_login.py`    | Login test cases                   |
| `test_register.py` | Register test cases                |
| `base_page.py`     | Common page methods                |
| `requirements.txt` | Python dependencies                |
| `README.md`        | Full documentation                 |

## 🎯 Test Data

Edit in `config/test_config.py`:

```python
VALID_EMAIL = "test@example.com"
VALID_PASSWORD = "Test@123456"
VALID_NAME = "Test User"
VALID_PHONE = "0987654321"
VALID_OTP = "123456"
```

## 📸 Screenshots

Failed test screenshots saved in:

```
appium_test/test_cases/screenshots/
```

---

For detailed documentation, see [README.md](README.md)
