# 📱 HƯỚNG DẪN CHẠY PATROL E2E TESTS - CHI TIẾT TỪNG BƯỚC

## ✅ HIỆN TẠI BẠN CÓ

- ✅ Patrol CLI v3.10.0 (đã cài & sẵn sàng)
- ✅ Android device SM A325F (API 33) kết nối
- ✅ Test files trong `integration_test/` folder:
  - `app_test.dart` - Main entry point
  - `login_test.dart` - 7 login tests
  - `register_test.dart` - 10 register tests
  - `test_helpers.dart` - Helper functions

---

## 🚀 CÁCH CHẠY TESTS - 3 PHƯƠNG PHÁP

### PHƯƠNG PHÁP 1: Đơn Giản Nhất (Khuyến Nghị)

```bash
cd /home/thao/Video_Al_App
patrol test -t integration_test/app_test.dart -d RF8R32EP5RY
```

**Giải thích:**

- `-t integration_test/app_test.dart` : File test entry point
- `-d RF8R32EP5RY` : Device ID (Android device của bạn)

**Kết quả dự kiến:**

```
Building apk...
Executing tests...
✓ Test 1: example test
Report: file:///...
```

---

### PHƯƠNG PHÁP 2: Chạy Login Tests Riêng

```bash
cd /home/thao/Video_Al_App
patrol test -t integration_test/login_test.dart -d RF8R32EP5RY
```

**Khi nào dùng:** Chỉ muốn test tính năng đăng nhập

---

### PHƯƠNG PHÁP 3: Chạy Register Tests Riêng

```bash
cd /home/thao/Video_Al_App
patrol test -t integration_test/register_test.dart -d RF8R32EP5RY
```

**Khi nào dùng:** Chỉ muốn test tính năng đăng ký

---

## 📋 HƯỚNG DẪN CHI TIẾT - LẦN ĐẦU CHẠY

### BƯỚC 1: Mở Terminal

```bash
cd /home/thao/Video_Al_App
```

### BƯỚC 2: Kiểm tra Device

```bash
flutter devices
```

**Output sẽ như này:**

```
Found 3 connected devices:
  SM A325F (mobile) • RF8R32EP5RY • android-arm64  • Android 13 (API 33) ✅
  ...
```

Ghi nhớ: **RF8R32EP5RY** là device ID của bạn

### BƯỚC 3: Chạy Test

```bash
patrol test -t integration_test/app_test.dart -d RF8R32EP5RY
```

### BƯỚC 4: Theo dõi Quá trình

**Phase 1: Build (30-60 giây)**

```
• Building apk with entrypoint test_bundle.dart...
  [Các thông báo cảnh báo có thể xuất hiện - bỏ qua]
✓ Completed building apk (26.8s)
```

**Phase 2: Run Tests (20-30 giây)**

```
• Executing tests...
• Test 1: example test ✓
• Test 2: ... ✓
```

**Phase 3: Report**

```
Test summary:
📝 Total: 1
✅ Successful: 1
❌ Failed: 0
```

---

## 🔍 CÁC TÌNH HUỐNG & GIẢI PHÁP

### ❌ Lỗi: "target directory android does not contain any tests"

**Nguyên nhân:** Không chỉ định đúng test file  
**Giải pháp:**

```bash
# ❌ SAIIF
patrol test --target android

# ✅ ĐÚNG
patrol test -t integration_test/app_test.dart -d RF8R32EP5RY
```

### ❌ Lỗi: "No devices found"

**Nguyên nhân:** Device chưa kết nối hoặc em trong mode Airplane  
**Giải pháp:**

```bash
# Kiểm tra device
flutter devices

# Nếu không có device:
# 1. Kết nối Android phone qua USB
# 2. Bật USB Debugging trên phone
# 3. Chạy lại: flutter devices
```

### ❌ Lỗi: "Build failed"

**Nguyên nhân:** Dependencies hoặc gradle issue  
**Giải pháp:**

```bash
# Clean & rebuild
flutter clean
flutter pub get
flutter pub upgrade

# Sau đó chạy lại test
patrol test -t integration_test/app_test.dart -d RF8R32EP5RY
```

### ⚠️ Warnings (Android Gradle Plugin, Kotlin)

**Không ảnh hưởng:** Những warnings này không làm hỏng tests  
**Bỏ qua:** Tests sẽ vẫn chạy bình thường

---

## 📊 THEO DÕI TESTS TRÊN DEVICE

Trong lúc tests chạy, bạn sẽ thấy:

1. **App tự cài đặt** trên SM A325F
2. **UI tự động** interact (nhấp, nhập text)
3. **Kết quả** hiển thị trên terminal

---

## 🎯 ADVANCED: Custom Commands

### Chạy với Verbose Mode (xem chi tiết)

```bash
patrol test -t integration_test/app_test.dart -d RF8R32EP5RY --verbose
```

### Lưu Output vào File

```bash
patrol test -t integration_test/app_test.dart -d RF8R32EP5RY > test_results.txt 2>&1
```

### Chạy trên Emulator

```bash
# Nếu dùng emulator thay vì device thực:
flutter emulators
emulator -avd <emulator_name>

# Sau đó chạy tests như bình thường
patrol test -t integration_test/app_test.dart
```

---

## 🧪 NEXT STEPS SAU KHI CHẠY

### Nếu Tests Pass ✅

1. Thêm tests cho features khác
2. Tích hợp vào CI/CD
3. Chạy định kỳ

### Nếu Tests Fail ❌

1. Đọc error message
2. Xem logs: `adb logcat`
3. Kiểm tra test code
4. Sửa lỗi & chạy lại

---

## 💡 LƯU Ý QUAN TRỌNG

1. **Device cần bật & mở khóa** - Làm sao tests có thể chạy?
2. **USB Debugging bật** - Nếu là device thực
3. **Network:**
   - App cần kết nối Internet (API)
   - Hoặc mock API responses
4. **Test account:**
   - Cần account test để login
   - Hoặc mock authentication

---

## 🚀 COPY-PASTE READY COMMANDS

### Lần đầu: Setup & Test

```bash
cd /home/thao/Video_Al_App
flutter devices
flutter clean
flutter pub get
patrol test -t integration_test/app_test.dart -d RF8R32EP5RY
```

### Lần sau: Chạy ngay

```bash
cd /home/thao/Video_Al_App
patrol test -t integration_test/app_test.dart -d RF8R32EP5RY
```

### Chạy tất cả test files

```bash
cd /home/thao/Video_Al_App
patrol test -t integration_test/app_test.dart -d RF8R32EP5RY
patrol test -t integration_test/login_test.dart -d RF8R32EP5RY
patrol test -t integration_test/register_test.dart -d RF8R32EP5RY
```

---

## 📞 NẾUF CẦN HELP

1. **Xem documentation:**

   - `test_driver/README.md`
   - `TEST_GUIDE.md`
   - `QUICK_REFERENCE.md`

2. **Check logs:**

   ```bash
   adb logcat
   ```

3. **Clean & rebuild:**
   ```bash
   flutter clean && flutter pub get
   ```

---

**READY?** 🚀

```bash
patrol test -t integration_test/app_test.dart -d RF8R32EP5RY
```

Chúc bạn thành công!
