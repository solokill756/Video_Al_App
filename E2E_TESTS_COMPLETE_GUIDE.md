# 🧪 Integration Tests - Complete Guide

## ✅ Test Status Summary

| Test                    | Status     | Details                                                      |
| ----------------------- | ---------- | ------------------------------------------------------------ |
| **UI Interaction Test** | ✅ PASS    | `final_login_test.dart` - All UI interactions work perfectly |
| **API Connectivity**    | ✅ PASS    | Server responds, login endpoint works                        |
| **API Authentication**  | ✅ PASS    | admin@gmail.com / admin123 returns valid tokens              |
| **Real E2E Login Test** | ⏳ TIMEOUT | App-to-API flow needs investigation                          |

---

## 🎯 Quick Start

### 1️⃣ Run UI Interaction Test (Recommended - WORKS!)

```bash
cd /home/thao/Video_Al_App
flutter test integration_test/final_login_test.dart -d RF8R32EP5RY
```

**Expected Output:**

```
✅ App loaded and rendered
✅ Login form is visible
✅ Text fields are interactive
✅ Email entry works
✅ Password entry works
✅ Login button is clickable
✅ Navigation links are available
🎉 All user interactions completed successfully!
```

### 2️⃣ Test API Connectivity

```bash
flutter test test/api_connectivity_test.dart
```

**Expected Output:**

```
✅ Login response received:
  Status: 200
  Data: {accessToken: ..., refreshToken: ...}
```

### 3️⃣ Run Complete Login Interaction

```bash
flutter test integration_test/real_api_login_test.dart -d RF8R32EP5RY
```

---

## 📝 Test Files Created

### Integration Tests (In `integration_test/` folder)

1. **`final_login_test.dart`** ⭐ BEST FOR LEARNING

   - ✅ Fully working
   - Tests actual UI interactions
   - Shows all 8 steps with clear output
   - Great for understanding test flow

2. **`real_api_login_test.dart`**

   - Tests with real API credentials
   - Uses admin@gmail.com / admin123
   - Attempts full E2E flow
   - Currently times out (needs debugging)

3. **`real_login_test.dart`**

   - Multiple test cases grouped
   - Covers 7 different scenarios
   - Previously had issues with app.main() init time

4. **`e2e_test.dart`**
   - Simple basic test
   - Good for quick validation

### Unit Tests (In `test/` folder)

1. **`api_connectivity_test.dart`** ✅ WORKS!
   - Tests direct API calls
   - Validates server connectivity
   - Confirms credentials work
   - Status: All tests pass

---

## 🔍 Key Findings

### ✅ What Works

1. **App UI Rendering**: App loads in ~4 seconds
2. **Form Interaction**: Text fields respond to tap and text entry
3. **Navigation Links**: "Forgot Password" and "Sign Up" links are clickable
4. **API Server**: Server is reachable and responsive
5. **Authentication**: Credentials work and return valid tokens

### ⚠️ Issues Found

1. **App Init Delay**: AuthGuard checks `Storage.accessToken` (async call to secure storage)

   - Takes ~4 seconds
   - Expected behavior for first load

2. **E2E Timeout**: App login flow times out

   - Possible causes:
     - Token not being persisted correctly
     - Navigation not being triggered after login
     - BLoC state not updating

3. **Network**: Some requests may be slow in test environment

---

## 📊 Credentials for Testing

```
Email:    admin@gmail.com
Password: admin123
```

### Server Info

```
API Base URL: https://lifelog-challenge-server.dangxuankhanh.io.vn/api
Environment: DEV
Package: com.fau.videoal
```

---

## 🎓 How Tests Work

### Test Flow

```
1. Start app
   ↓
2. Wait for login page to render
   ↓
3. Find TextFields
   ↓
4. Enter email
   ↓
5. Enter password
   ↓
6. Tap login button
   ↓
7. Wait for API response
   ↓
8. Check if navigation occurred
```

### Test Helpers

The tests use these main Flutter testing concepts:

```dart
app.main()                           // Start app
await tester.pump(duration)          // Render frame
await tester.pumpAndSettle()         // Wait for animation
find.byType(TextField)               // Find widget by type
find.text('Login')                   // Find widget by text
await tester.tap(widget)             // Simulate tap
await tester.enterText(widget, text) // Enter text
```

---

## 🚀 Next Steps to Debug E2E

To fix the timeout issue:

1. **Check BLoC State**

   - Verify AuthCubit updates when login response arrives
   - Ensure state changes trigger navigation

2. **Check Token Storage**

   - Verify tokens are saved to secure storage
   - Check if auth guard navigation works

3. **Add More Logging**

   - Print BLoC state changes
   - Print API responses
   - Check navigation router logs

4. **Test in Stages**
   - Test API directly ✅ (Already works!)
   - Test form interaction ✅ (Already works!)
   - Test button tap → API call (Needs debug)
   - Test navigation after login (Needs debug)

---

## 📚 Test Command Reference

```bash
# Run specific test file
flutter test integration_test/final_login_test.dart -d DEVICE_ID

# Run all tests in a folder
flutter test integration_test/ -d DEVICE_ID

# Run with verbose output
flutter test integration_test/final_login_test.dart -d DEVICE_ID -v

# Run with seed for reproducibility
flutter test integration_test/final_login_test.dart -d DEVICE_ID --seed=12345

# Run on Android device
flutter test integration_test/final_login_test.dart -d RF8R32EP5RY

# Run on emulator
flutter test integration_test/final_login_test.dart -d emulator-5554
```

---

## 💡 Tips for Writing Tests

1. **Use `pump()` for single frame**: Faster than `pumpAndSettle()`
2. **Use `pumpAndSettle()` for navigation**: Waits for all animations
3. **Always add delays after taps**: Network calls need time
4. **Search for widgets by text first**: More reliable than by type
5. **Add print statements**: Helps debug when tests fail

---

## 🎉 Summary

**✅ UI Tests: WORKING PERFECTLY**

- App loads fine
- Forms interact correctly
- All UI elements are present and functional

**✅ API Tests: WORKING PERFECTLY**

- Server is reachable
- Login endpoint responds correctly
- Credentials are valid

**⏳ Full E2E: NEEDS DEBUGGING**

- UI + API works separately
- Combined flow needs investigation
- Likely state management or navigation issue

---

## 📞 Support

If tests fail:

1. Check device is connected: `flutter devices`
2. Check API is reachable: `curl https://lifelog-challenge-server.dangxuankhanh.io.vn/api/health`
3. Verify credentials: `admin@gmail.com / admin123`
4. Check logs: `adb logcat`
5. Run API test first to isolate issue

**Status**: Tests are comprehensive and well-structured. Ready for debugging E2E flow.
