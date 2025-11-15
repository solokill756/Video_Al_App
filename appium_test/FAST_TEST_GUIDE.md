# 🚀 HƯỚNG DẪN CHẠY TEST NHANH

## ✅ Các cải tiến đã thực hiện

### 1. Reset app trước mỗi test

- **Mỗi test tự động restart app** để quay về màn hình login
- Đảm bảo state sạch cho mỗi test case
- Sử dụng `driver.terminate_app()` và `driver.activate_app()`

### 2. Tối ưu hóa tốc độ

- **FAST_MODE** đã được đặt làm mặc định
- Giảm timeout xuống 8s (thay vì 30s)
- Giảm delay sau action xuống 0.2s (thay vì 2s)
- Giảm delay sau ẩn keyboard xuống 0.15s (thay vì 1s)

### 3. Credentials chính xác

- Email: **admin@gmail.com**
- Password: **admin123**

## 📊 So sánh tốc độ

| Chế độ                | Timeout | Delay sau action | Thời gian (8 tests) |
| --------------------- | ------- | ---------------- | ------------------- |
| **WATCHABLE** (debug) | 30s     | 2.0s             | ~180s (3 phút)      |
| **NORMAL** (cân bằng) | 15s     | 0.5s             | ~90s (1.5 phút)     |
| **FAST** (nhanh)      | 8s      | 0.2s             | ~50-60s (1 phút)    |

## 🎯 Cách chạy test

### Chạy tất cả login tests (khuyến nghị):

```bash
cd /home/thao/Video_Al_App/appium_test
source venv/bin/activate
python3 -m unittest test_cases.test_login -v
```

### Hoặc dùng script với timer:

```bash
cd /home/thao/Video_Al_App/appium_test
./run_login_tests_fast.sh
```

### Chạy test nhanh với 2 tests cơ bản:

```bash
cd /home/thao/Video_Al_App/appium_test
source venv/bin/activate
python3 run_quick_test.py
```

### Chạy 1 test cụ thể:

```bash
cd /home/thao/Video_Al_App/appium_test
source venv/bin/activate
python3 -m unittest test_cases.test_login.LoginTests.test_02_login_with_valid_credentials -v
```

## 📝 Danh sách 8 Login Tests

1. **test_01_login_page_displayed** ✅

   - Kiểm tra màn hình login hiển thị

2. **test_02_login_with_valid_credentials** ✅

   - Login với admin@gmail.com / admin123
   - Phải chuyển sang màn hình home

3. **test_03_login_with_invalid_email** ✅

   - Login với email không hợp lệ
   - Phải hiển thị lỗi validation

4. **test_04_login_with_empty_email** ✅

   - Login với email trống
   - Phải hiển thị lỗi

5. **test_05_login_with_empty_password** ✅

   - Login với password trống
   - Phải hiển thị lỗi

6. **test_06_login_with_wrong_password** ✅

   - Login với sai password
   - Phải hiển thị lỗi

7. **test_07_navigate_to_register** ✅

   - Nhấn link "Sign up now"
   - Phải chuyển sang màn hình register

8. **test_08_navigate_to_forgot_password** ✅
   - Nhấn link "Forgot password?"
   - Phải chuyển sang màn hình forgot password

## 🔧 Thay đổi tốc độ test

### Để chạy ở chế độ WATCHABLE (xem từng bước):

Sửa file `config/speed_config.py`:

```python
CURRENT_MODE = WATCHABLE_MODE  # Thay vì FAST_MODE
```

### Để chạy ở chế độ NORMAL (cân bằng):

```python
CURRENT_MODE = NORMAL_MODE
```

### Để quay lại FAST (nhanh nhất):

```python
CURRENT_MODE = FAST_MODE  # Mặc định
```

## 🎬 Quy trình mỗi test

1. **setUp()**: Restart app → Quay về màn hình login
2. **test_xx()**: Thực hiện test case
3. **tearDown()**: Chụp screenshot nếu fail
4. Lặp lại cho test tiếp theo

## 📸 Screenshots khi test fail

- Tự động lưu vào thư mục `screenshots/`
- Tên file: `login_test_<test_name>_failed.png`
- Giúp debug dễ dàng

## ⚠️ Lưu ý

1. **Appium server phải đang chạy**:

   ```bash
   cd /home/thao/Video_Al_App/appium_test
   ./start_appium.sh
   ```

2. **Device phải được kết nối**:

   ```bash
   adb devices
   ```

3. **App đã được cài đặt** trên device

4. **Tài khoản admin@gmail.com phải tồn tại** trong hệ thống backend

## 🎯 Kết quả mong đợi

```
test_01_login_page_displayed ... ok
test_02_login_with_valid_credentials ... ok
test_03_login_with_invalid_email ... ok
test_04_login_with_empty_email ... ok
test_05_login_with_empty_password ... ok
test_06_login_with_wrong_password ... ok
test_07_navigate_to_register ... ok
test_08_navigate_to_forgot_password ... ok

----------------------------------------------------------------------
Ran 8 tests in ~60s

OK
```

## 🐛 Troubleshooting

### Test chậm?

- Kiểm tra `speed_config.py` có đang dùng FAST_MODE không
- Giảm timeout xuống 5-8s nếu device nhanh

### App không restart?

- Kiểm tra driver có quyền terminate app không
- Thử dùng `adb shell am force-stop com.fau.dmvgenie` thủ công

### Test fail do timing?

- Tăng timeout lên 10s
- Hoặc chuyển sang NORMAL_MODE

### Login thành công nhưng test fail?

- Kiểm tra method `is_login_successful()` trong `login_page.py`
- Cần verify đúng element trên home screen
