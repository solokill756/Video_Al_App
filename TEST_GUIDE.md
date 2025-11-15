# 📱 Hướng dẫn Patrol E2E Tests - Đăng nhập & Đăng ký

Tôi đã tạo bộ test E2E (End-to-End) toàn diện cho ứng dụng Flutter của bạn sử dụng **Patrol Framework**.

## 📋 Nội dung tạo ra

```
test_driver/
├── integration_test.dart    ← File cấu hình chính
├── login_test.dart          ← 7 test cho đăng nhập
├── register_test.dart       ← 10 test cho đăng ký
├── test_helpers.dart        ← Helper functions để tái sử dụng
├── README.md                ← Tài liệu chi tiết
└── patrol.yaml              ← Cấu hình Patrol

pubspec.yaml                 ← Đã thêm patrol: ^3.6.0
```

## 🧪 Tests cho Đăng nhập (7 tests)

| #   | Test                    | Mô tả                                            |
| --- | ----------------------- | ------------------------------------------------ |
| 1   | ✅ Valid Login          | Đăng nhập thành công với email & password hợp lệ |
| 2   | ❌ Invalid Email        | Lỗi khi email không hợp lệ (không có @)          |
| 3   | ❌ Empty Email          | Lỗi khi email trống                              |
| 4   | ❌ Empty Password       | Lỗi khi password trống                           |
| 5   | 🔄 Navigate to Register | Điều hướng sang trang đăng ký                    |
| 6   | 👁️ Toggle Password      | Ẩn/hiện mật khẩu                                 |
| 7   | 🔐 Forgot Password      | Điều hướng sang trang quên mật khẩu              |

## 📝 Tests cho Đăng ký (10 tests)

| #   | Test             | Mô tả                        |
| --- | ---------------- | ---------------------------- |
| 1   | 📄 Navigate Page | Mở trang đăng ký             |
| 2   | ✅ Valid Email   | Tiếp tục với email hợp lệ    |
| 3   | ❌ Invalid Email | Lỗi với email không hợp lệ   |
| 4   | ❌ Empty Email   | Lỗi khi email trống          |
| 5   | 🔄 Back to Login | Quay lại trang đăng nhập     |
| 6   | 👁️ Google Button | Xem nút Google Sign In       |
| 7   | 🔘 Click Google  | Nhấp nút Google Sign In      |
| 8   | 📲 OTP Page      | Kiểm tra trang OTP           |
| 9   | 📋 Fill Details  | Điền thông tin sau OTP       |
| 10  | ✓ Form Fields    | Kiểm tra các trường bắt buộc |

## 🚀 Cách chạy tests

### 1. **Cài đặt Patrol CLI**

```bash
dart pub global activate patrol_cli
```

### 2. **Cài đặt dependencies**

```bash
flutter pub get
```

### 3. **Chạy tests trên Android**

```bash
# Chạy tất cả tests
patrol test --target android

# Chạy test đăng nhập
patrol test -t test_driver/login_test.dart --target android

# Chạy test đăng ký
patrol test -t test_driver/register_test.dart --target android

# Chạy test cụ thể
patrol test --target android --test 'User can login with valid credentials'
```

### 4. **Chạy tests trên iOS**

```bash
patrol test --target ios
patrol test -t test_driver/login_test.dart --target ios
```

## 🛠️ Cấu trúc Test Files

### `login_test.dart`

- Sử dụng pattern: `patrolTest()` từ Patrol
- Tương tác: điền email → điền password → nhấp login
- Assertions: kiểm tra SnackBar lỗi, điều hướng, v.v.

### `register_test.dart`

- Flow: trang đăng ký → điền email → OTP → chi tiết đăng ký
- Kiểm tra validation email
- Kiểm tra Google Sign In button

### `test_helpers.dart`

Chứa các hàm tiện ích:

```dart
TestHelpers.fillEmailField($, 'user@example.com');
TestHelpers.fillPasswordField($, 'password123');
TestHelpers.clickLoginButton($);
TestHelpers.navigateToRegister($);
// ... và nhiều hàm khác
```

## 📊 Tương tác UI được test

| Thao tác    | Widget               | Test                       |
| ----------- | -------------------- | -------------------------- |
| Điền text   | TextField            | ✅ Cả email & password     |
| Nhấp button | ElevatedButton       | ✅ Login, Register, Google |
| Navigate    | GestureDetector/Link | ✅ Sang trang khác         |
| Validate    | SnackBar             | ✅ Lỗi validation          |
| Toggle      | IconButton           | ✅ Ẩn/hiện password        |

## 🎯 Best Practices được áp dụng

✅ **Separation of Concerns** - Các test riêng biệt theo tính năng  
✅ **Reusable Helpers** - `test_helpers.dart` tránh trùng lặp code  
✅ **Clear Names** - Tên test miêu tả rõ ràng mục đích  
✅ **Proper Waits** - `pumpAndSettle()` sau mỗi hành động  
✅ **Assertions** - Kiểm tra kết quả bằng `expect()`

## 📝 Ghi chú quan trọng

### Để chạy tests successfully, cần:

1. **Emulator/Device chạy** - Khởi động Android emulator hoặc kết nối iOS device

   ```bash
   flutter devices  # Liệt kê devices có sẵn
   ```

2. **Mock API** (nếu cần) - Nếu tests thực hiện call API, cần mock responses
3. **Test Data** - Sử dụng test accounts có sẵn

### Tối ưu hóa tests

Bạn có thể thêm `Key` vào widgets để tìm chính xác hơn:

**Trong code chính (login_page.dart):**

```dart
TextField(
  key: const ValueKey('emailInput'),
  controller: _emailController,
  ...
)
```

**Trong test:**

```dart
await $(find.byKey(const ValueKey('emailInput'))).enterText('user@example.com');
```

## 🔗 Tài liệu tham khảo

- 📖 [Patrol Official Docs](https://patrol.dev/)
- 🧪 [Flutter Testing Guide](https://flutter.dev/docs/testing)
- 📱 [Integration Testing](https://flutter.dev/docs/testing/integration-tests)

## ❓ Câu hỏi thường gặp

**Q: Làm sao để chạy test trên device thực?**  
A: `patrol test --target android --device <device-id>`

**Q: Làm sao để debug test?**  
A: Thêm `--verbose` flag: `patrol test --target android -v`

**Q: Có thể chạy test trên web không?**  
A: Patrol chủ yếu hỗ trợ Android/iOS, nhưng có thể dùng `flutter test` cho web.

**Q: Làm sao để tăng timeout?**  
A: Chỉnh sửa `patrol.yaml`: `testTimeout: 600000` (milliseconds)

## 🎓 Ví dụ sử dụng

### Test đơn giản - Đăng nhập thành công

```dart
patrolTest('User can login', ($) async {
  await $.pumpAndSettle();
  await TestHelpers.performLogin($, 'user@example.com', 'password123');
  // Kiểm tra kết quả...
});
```

### Test phức tạp - Đầy đủ flow đăng ký

```dart
patrolTest('Complete registration flow', ($) async {
  // Điều hướng
  await $.pumpAndSettle();
  await TestHelpers.navigateToRegister($);

  // Điền email
  await TestHelpers.performRegister($, 'newuser@example.com');

  // Kiểm tra OTP page
  expect(find.byType(OtpWidget), findsOneWidget);
});
```

## ✨ Kết luận

Bạn đã có một bộ test E2E hoàn chỉnh cho ứng dụng! 🎉

**Tiếp theo:**

1. Chạy tests lần đầu: `patrol test --target android`
2. Fix lỗi nếu có
3. Thêm tests cho các tính năng khác
4. Integrate vào CI/CD pipeline

Chúc bạn test vui vẻ! 🚀
