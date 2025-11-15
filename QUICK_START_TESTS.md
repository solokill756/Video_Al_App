# 🚀 Quick Start - Run Tests in 2 Minutes

## One Command - Full Verification

```bash
cd /home/thao/Video_Al_App && \
echo "=== API Test ===" && \
flutter test test/api_connectivity_test.dart && \
echo -e "\n=== UI Test ===" && \
flutter test integration_test/final_login_test.dart -d RF8R32EP5RY
```

---

## Test Commands

### API Test (2 minutes)

```bash
flutter test test/api_connectivity_test.dart
```

Verifies server works and login returns JWT tokens

### UI Test (5 minutes)

```bash
flutter test integration_test/final_login_test.dart -d RF8R32EP5RY
```

Verifies form interactions work perfectly

### E2E Test (10 minutes)

```bash
flutter test integration_test/real_api_login_test.dart -d RF8R32EP5RY
```

Tests complete login flow with real API

### Debug Test (10 minutes)

```bash
flutter test integration_test/debug_login_e2e_test.dart -d RF8R32EP5RY -v
```

Shows detailed steps of what's happening

---

## Test Credentials

```
Email: admin@gmail.com
Password: admin123
```

---

## Expected Results

### ✅ API Test Output

```
✅ Login response received:
Status: 200
Data: {accessToken: ..., refreshToken: ...}
All tests passed!
```

### ✅ UI Test Output

```
✅ App loaded and rendered
✅ Login form is visible
✅ Text fields are interactive
✅ Email entry works
✅ Password entry works
✅ Login button is clickable
🎉 All user interactions completed successfully!
```

### ✅ E2E Test Output

Should show login completing and navigating to home screen

---

## Device Setup

Device connected: Samsung A325F (RF8R32EP5RY)

```bash
# Check device
flutter devices

# Output should show:
# RF8R32EP5RY (mobile) • SM-A325F • android-arm64 • Android 13 (API 33)
```

---

## What to Do With Results

### All Tests Pass ✅

Perfect! The app is ready for:

- User login testing
- Register/signup testing
- Forgot password testing
- Token refresh testing

### Some Tests Fail ❌

Check the error message:

- **API test fails** → Backend issue
- **UI test fails** → Form elements missing
- **E2E test fails** → Navigation or state management issue

---

## Shortcuts

### Run all at once

```bash
./run_all_tests.sh
```

### Run only quick tests

```bash
flutter test test/ integration_test/final_login_test.dart -d RF8R32EP5RY
```

### Run with verbose logging

```bash
flutter test integration_test/final_login_test.dart -d RF8R32EP5RY -v
```

---

## Troubleshooting

If device not found:

```bash
flutter devices
adb devices -l
```

If test hangs:

- Press Ctrl+C to stop
- Check app on device is still running
- Try again

If API test fails:

- Check internet connection
- Verify API endpoint is accessible
- Check credentials

---

## Next Steps

1. Run UI test
2. Run API test
3. Run E2E test
4. Create register tests (if needed)
5. Create forgot password tests (if needed)
6. Create error scenario tests (if needed)

---

Good luck! 🎉
