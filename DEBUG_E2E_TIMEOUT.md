# 🔧 Debugging E2E Login Timeout

## Problem Statement

**Test**: `real_api_login_test.dart`
**Status**: Times out waiting for successful login
**API Status**: ✅ Confirmed working - returns HTTP 200 with valid tokens
**UI Status**: ✅ Confirmed working - all interactions possible

**Root Cause**: Unknown - likely app-side handling after login response

---

## Investigation Checklist

### Step 1: Verify AuthCubit State Changes

Check if `AuthCubit` emits success state when login response arrives:

```dart
// In integration_test/debug_auth_state_test.dart
void main() {
  group('Auth State Debug Test', () {
    testWidgets('Check AuthCubit emits success state', (WidgetTester tester) async {
      // Capture all BLoC events
      List<String> stateChanges = [];

      await tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      app.main();
      await tester.pump(const Duration(seconds: 4));

      // Enter credentials
      await tester.enterText(find.byType(TextField).first, 'admin@gmail.com');
      print('✅ Email entered');

      await tester.enterText(find.byType(TextField).at(1), 'admin123');
      print('✅ Password entered');

      // Tap login and monitor states
      await tester.tap(find.text('LOGIN').first);
      print('🔄 Login button tapped');

      // Wait and pump multiple times to see state changes
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        print('⏳ Wait cycle $i');
      }

      print('❌ Test completed with timeout');
    });
  });
}
```

### Step 2: Check Token Storage

Verify tokens are saved after login:

```dart
// In integration_test/verify_token_storage_test.dart
void main() {
  testWidgets('Verify tokens stored after login', (WidgetTester tester) async {
    app.main();
    await tester.pump(const Duration(seconds: 5));

    // Login
    await tester.enterText(find.byType(TextField).first, 'admin@gmail.com');
    await tester.enterText(find.byType(TextField).at(1), 'admin123');
    await tester.tap(find.text('LOGIN').first);

    // Wait for storage
    await tester.pumpAndSettle(const Duration(seconds: 15));

    // Try to read from secure storage
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    print('📦 Stored token: ${token ?? 'NOT FOUND'}');
    expect(token, isNotNull);
  });
}
```

### Step 3: Monitor Navigation

Check if router actually navigates:

```dart
// In integration_test/verify_navigation_test.dart
void main() {
  testWidgets('Verify navigation after login', (WidgetTester tester) async {
    app.main();
    await tester.pump(const Duration(seconds: 5));

    print('🏠 Initial: Should be on login page');
    expect(find.byType(LoginPage), findsOneWidget);

    // Login
    await tester.enterText(find.byType(TextField).first, 'admin@gmail.com');
    await tester.enterText(find.byType(TextField).at(1), 'admin123');
    await tester.tap(find.text('LOGIN').first);

    // Wait for navigation
    await tester.pumpAndSettle(const Duration(seconds: 15));

    print('🎯 After login: Check current page');

    // Check if navigated away from login
    if (find.byType(LoginPage).evaluate().isEmpty) {
      print('✅ Successfully navigated away from login!');
    } else {
      print('❌ Still on login page after 15 seconds');
    }
  });
}
```

### Step 4: Add Detailed Logging

Modify your app to log during login:

```dart
// Add to auth_cubit.dart loginUser method:
Future<void> loginUser(String email, String password) async {
  try {
    print('🔐 [AUTH] Starting login for: $email');
    emit(AuthLoading());

    final response = await _authRepository.login(
      email: email,
      password: password,
    );

    print('🔐 [AUTH] Got response: ${response.accessToken}');

    await _storage.saveAccessToken(response.accessToken);
    print('🔐 [AUTH] Token saved to storage');

    await _storage.saveRefreshToken(response.refreshToken);
    print('🔐 [AUTH] Refresh token saved');

    emit(AuthAuthenticated(user: response.user));
    print('🔐 [AUTH] Emitted AuthAuthenticated state');

  } catch (e) {
    print('❌ [AUTH] Error: $e');
    emit(AuthError(message: e.toString()));
  }
}
```

---

## Common Issues & Solutions

### Issue 1: Token Not Being Saved

**Symptom**: Login works but app doesn't navigate

**Solution**:

```dart
// Check secure storage implementation
final storage = const FlutterSecureStorage();
await storage.write(key: 'accessToken', value: token);
final saved = await storage.read(key: 'accessToken');
print('Token saved: $saved');
```

### Issue 2: BLoC Not Emitting Success

**Symptom**: API responds but BLoC still in loading state

**Solution**:

```dart
// Make sure to emit state BEFORE navigation
emit(AuthAuthenticated(user: user));  // This MUST happen
// Then router picks it up and navigates
```

### Issue 3: Navigation Not Triggered

**Symptom**: AuthAuthenticated state emitted but no navigation

**Solution**:

- Check `AuthGuard` is properly observing `AuthCubit`
- Verify router is configured correctly
- Check initial route is set

### Issue 4: Timeout on Secure Storage

**Symptom**: Storage operations taking too long

**Solution**:

```dart
// Use timeout wrapper
Future<void> saveTokenWithTimeout(String token) async {
  try {
    await _storage.write(key: 'accessToken', value: token)
        .timeout(const Duration(seconds: 5));
  } on TimeoutException {
    print('❌ Storage write timeout');
    rethrow;
  }
}
```

---

## Step-by-Step Debugging Process

### 1. Run API Test (Already ✅ Working)

```bash
flutter test test/api_connectivity_test.dart
```

Verify: API returns 200 with tokens

### 2. Run UI Test (Already ✅ Working)

```bash
flutter test integration_test/final_login_test.dart -d RF8R32EP5RY
```

Verify: All form interactions work

### 3. Add State Debug Test

```bash
# Create and run the debug test from Step 1
flutter test integration_test/debug_auth_state_test.dart -d RF8R32EP5RY -v
```

Check: Does AuthCubit emit success state?

### 4. Add Storage Debug Test

```bash
flutter test integration_test/verify_token_storage_test.dart -d RF8R32EP5RY -v
```

Check: Are tokens actually stored?

### 5. Add Navigation Debug Test

```bash
flutter test integration_test/verify_navigation_test.dart -d RF8R32EP5RY -v
```

Check: Does app navigate away from login?

### 6. Enable App Logging

Modify `auth_cubit.dart` to add print statements (see Step 4 above)

### 7. Run Full E2E with Logging

```bash
flutter test integration_test/real_api_login_test.dart -d RF8R32EP5RY -v
```

Check: Full flow with all logging visible

---

## Expected Results

### If Tests Pass ✅

- AuthCubit emits success state
- Tokens are stored
- Navigation occurs
- App reaches home screen

### If Tests Fail ❌

- Narrow down which step fails
- Fix that specific issue
- Re-run test

---

## Quick Diagnosis Tree

```
E2E Test Times Out
    ↓
1. API responds 200?
   YES → Continue
   NO → Fix API (already confirmed working)

2. BLoC emits success state?
   YES → Continue
   NO → Fix AuthCubit in auth_cubit.dart

3. Tokens stored?
   YES → Continue
   NO → Fix secure storage

4. Navigation triggered?
   YES → Increase test timeout
   NO → Fix AuthGuard or router

5. On home page?
   YES → TEST PASSES! 🎉
   NO → Check page widgets
```

---

## Test Commands

```bash
# Run with verbose logging
flutter test integration_test/real_api_login_test.dart -d RF8R32EP5RY -v 2>&1 | head -100

# Run and capture all output
flutter test integration_test/real_api_login_test.dart -d RF8R32EP5RY > test_output.txt 2>&1

# Run specific test with timeout info
flutter test integration_test/real_api_login_test.dart -d RF8R32EP5RY --verbose --timeout=60s
```

---

## Success Criteria

✅ **Test Passes When**:

1. App loads successfully
2. Login form accepts input
3. Login button tap triggers API call
4. API responds with 200 + tokens
5. Tokens are stored in secure storage
6. AuthCubit emits success state
7. Router navigates to home screen
8. Test completes without timeout

---

## Contact Points in Code

- **Login Logic**: `lib/src/features/auth/presentation/cubits/auth_cubit.dart`
- **API Call**: `lib/src/features/auth/data/repositories/auth_repository.dart`
- **Routing**: `lib/src/core/router/router.dart`
- **Auth Guard**: `lib/src/core/router/guards/auth_guard.dart`
- **Storage**: `lib/src/core/services/storage_service.dart`

---

## Next Action

Start with **Step 1** and **Step 3** to determine where the flow breaks.
