# Hướng dẫn sử dụng Patrol Tests cho Authentication

## Tổng quan

Tôi đã tạo một bộ test hoàn chỉnh cho module Authentication sử dụng Patrol framework. Bộ test này bao gồm 13 test cases kiểm tra các tình huống khác nhau.

## Cấu trúc Files

### 1. `test/test_helpers.dart`

File chứa các mock classes và helper functions:

- **MockAuthRepository**: Mock cho AuthRepository
- **MockSettingsRepository**: Mock cho SettingsRepository
- **setupMockDependencies()**: Hàm setup các dependencies giả lập
- **pumpApp()**: Hàm khởi tạo app với các mock dependencies
- **registerFallbackValues()**: Đăng ký các fallback values cho Mocktail
- Các mock data constants (mockApiError, mockLoginResponse, mockUserNo2FA, mockUserWith2FA, etc.)

### 2. `test/auth_flow_test.dart`

File chứa 13 test cases:

1. **Test 1: Đăng nhập thất bại - Sai thông tin**

   - Kiểm tra việc hiển thị lỗi khi đăng nhập với thông tin sai

2. **Test 2: Đăng nhập thành công - Không có 2FA**

   - Kiểm tra đăng nhập thành công cho user không bật 2FA

3. **Test 3: Đăng nhập thành công - Có 2FA**

   - Kiểm tra flow đăng nhập với 2FA enabled

4. **Test 4: Validation - Email không hợp lệ**

   - Kiểm tra validation email ở client-side

5. **Test 5: Validation - Thiếu mật khẩu**

   - Kiểm tra validation khi không nhập password

6. **Test 6: Validation - Email trống**

   - Kiểm tra validation khi không nhập email

7. **Test 7: Điều hướng - Chuyển đến trang đăng ký**

   - Kiểm tra navigation từ login sang register page

8. **Test 8: Điều hướng - Chuyển đến trang quên mật khẩu**

   - Kiểm tra navigation tới forgot password page

9. **Test 9: UI - Toggle hiển thị mật khẩu**

   - Kiểm tra tính năng show/hide password

10. **Test 10: Đăng ký - Gửi OTP thành công**

    - Kiểm tra flow gửi OTP khi đăng ký

11. **Test 11: Đăng ký - Validation email trống**

    - Kiểm tra validation email trống trong register

12. **Test 12: Đăng ký - Validation email không hợp lệ**

    - Kiểm tra validation email không hợp lệ trong register

13. **Test 13: Loading state - Hiển thị loading khi đăng nhập**
    - Kiểm tra loading state được hiển thị đúng

## Cách chạy tests

### Yêu cầu

- Device Android/iOS được kết nối hoặc emulator đang chạy
- Đã cài đặt Patrol CLI

### Lệnh chạy

```bash
# Chạy tất cả auth tests
patrol test --target test/auth_flow_test.dart

# Chạy với device cụ thể
patrol test --target test/auth_flow_test.dart -d <device-id>

# Chạy với verbose logging
patrol test --target test/auth_flow_test.dart --verbose
```

### Lưu ý quan trọng

⚠️ **KHÔNG sử dụng `flutter test` để chạy Patrol tests**

Patrol tests cần chạy trên thiết bị thực hoặc emulator, không thể chạy với `flutter test` command.

Lỗi bạn sẽ gặp nếu dùng `flutter test`:

```
LateInitializationError: Field 'patrolAppService' has not been initialized
```

## Các tính năng được test

### ✅ Login Flow

- Validation inputs (email, password)
- Đăng nhập thành công/thất bại
- Flow 2FA authentication
- Error handling
- Loading states

### ✅ Register Flow

- Validation email
- Gửi OTP
- Navigation đến register detail page

### ✅ Navigation

- Chuyển sang register page
- Chuyển sang forgot password page

### ✅ UI Interactions

- Toggle show/hide password
- Button states (enabled/disabled)
- Loading indicators

## Mô hình Testing

### Arrange-Act-Assert Pattern

Tất cả tests đều follow pattern AAA:

```dart
patrolTest('Test name', ($) async {
  // Arrange: Setup mocks và test data
  when(() => mockRepository.someMethod()).thenAnswer(...);

  // Act: Thực hiện actions
  await pumpApp($);
  await $.tap(someButton);

  // Assert: Verify kết quả
  expect($(someWidget), findsOneWidget);
});
```

### Mock Strategy

- Sử dụng Mocktail để mock repositories
- Setup mocks trong setUp() cho mỗi test
- Reset mocks trong tearDown()
- Sử dụng GetIt để dependency injection

## Troubleshooting

### Lỗi: "No device specified"

**Giải pháp**: Kết nối device hoặc start emulator trước khi chạy test

### Lỗi: "Gradle build failed"

**Giải pháp**:

- Chạy `flutter clean`
- Chạy `flutter pub get`
- Rebuild lại

### Lỗi: "Test not found"

**Giải pháp**: Đảm bảo file test_bundle.dart được generate đúng bởi Patrol

### Tests chạy chậm

**Giải pháp**:

- Tăng timeout trong patrol.yaml
- Sử dụng `$.pumpAndSettle()` thay vì multiple `$.pump()`

## Mở rộng Tests

### Thêm test mới

1. Thêm test case mới trong `auth_flow_test.dart`:

```dart
patrolTest(
  'Tên test case',
  ($) async {
    // Setup
    when(() => mockRepository...).thenAnswer(...);

    // Actions
    await pumpApp($);
    // ... your test actions

    // Assertions
    expect(...);
  },
);
```

2. Thêm mock data mới nếu cần trong `test_helpers.dart`

3. Chạy lại tests

### Best Practices

- ✅ Mỗi test nên độc lập, không phụ thuộc vào test khác
- ✅ Sử dụng descriptive test names (tiếng Việt OK)
- ✅ Test cả happy path và error cases
- ✅ Verify cả UI state và navigation
- ✅ Mock tất cả external dependencies
- ✅ Clean up trong tearDown()

## Tài liệu tham khảo

- [Patrol Documentation](https://patrol.leancode.co/)
- [Mocktail Documentation](https://pub.dev/packages/mocktail)
- [Flutter Testing Documentation](https://docs.flutter.dev/testing)

## Liên hệ

Nếu có vấn đề với tests, hãy kiểm tra:

1. Device/emulator đã kết nối chưa
2. Dependencies đã được install đúng chưa (`flutter pub get`)
3. Patrol CLI version (nên dùng phiên bản mới nhất)
4. Android/iOS build configuration
