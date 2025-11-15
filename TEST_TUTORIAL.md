# 🎯 HƯỚNG DẪN CHẠY TEST - DÀNH CHO BẠN

## Tóm tắt nhanh

Bạn đã có:

- ✅ 17 test cases (7 login + 10 register)
- ✅ Patrol CLI v3.10.0
- ✅ Android device kết nối
- ✅ Test files trong `integration_test/`

## Lệnh chạy test ngay bây giờ:

```bash
cd /home/thao/Video_Al_App && patrol test -t integration_test/app_test.dart -d RF8R32EP5RY
```

---

## CHI TIẾT CHO NGƯỜI MỚI

### BƯỚC 1: Mở Terminal/CMD

```bash
cd /home/thao/Video_Al_App
```

### BƯỚC 2: Đảm bảo device đã kết nối

```bash
flutter devices
```

**Kết quả sẽ hiển thị như này:**

```
Found 3 connected devices:
  SM A325F (mobile) • RF8R32EP5RY • android-arm64  • Android 13 (API 33) ✅
```

Nếu không thấy device:

1. Kết nối Android phone qua USB
2. Bật USB Debugging trên phone
3. Chạy lại lệnh trên

### BƯỚC 3: Chạy Test Đơn Giản

Dùng lệnh này để chạy test:

```bash
patrol test -t integration_test/app_test.dart -d RF8R32EP5RY
```

**Lệnh này sẽ:**

1. Build app (30-60 giây, lần đầu chậm)
2. Cài app trên device
3. Chạy tests (20-30 giây)
4. Hiển thị kết quả

### BƯỚC 4: Xem Kết Quả

Terminal sẽ hiển thị:

```
✓ Building apk... (26.8s)
✓ Executing tests...
Test summary:
  📝 Total: 1
  ✅ Successful: 1
  ❌ Failed: 0
```

---

## 3 CÁCH CHẠY TESTS

### Cách 1: App Launcher Test (HIỆN TẠI)

```bash
patrol test -t integration_test/app_test.dart -d RF8R32EP5RY
```

**Dùng khi:** Muốn test app launch

### Cách 2: Login Tests

```bash
patrol test -t integration_test/login_test.dart -d RF8R32EP5RY
```

**Dùng khi:** Muốn test tính năng đăng nhập

### Cách 3: Register Tests

```bash
patrol test -t integration_test/register_test.dart -d RF8R32EP5RY
```

**Dùng khi:** Muốn test tính năng đăng ký

---

## CÓ LỖI GÌ? GIẢI PHÁP

### ❌ Lỗi: "No devices found"

**Fix:**

```bash
# Kiểm tra lại device
flutter devices

# Nếu không có:
# - Kết nối USB + bật USB Debugging
# - Hoặc khởi động emulator
```

### ❌ Lỗi: "Build failed"

**Fix:**

```bash
flutter clean
flutter pub get
flutter pub upgrade

# Chạy lại
patrol test -t integration_test/app_test.dart -d RF8R32EP5RY
```

### ⚠️ Warnings (bỏ qua)

Warnings về Android Gradle hay Kotlin - không ảnh hưởng. Tests vẫn chạy bình thường.

---

## 🎓 CHUYÊN SÂU: Theo dõi Test

### Xem log chi tiết

```bash
patrol test -t integration_test/app_test.dart -d RF8R32EP5RY --verbose
```

### Lưu output ra file

```bash
patrol test -t integration_test/app_test.dart -d RF8R32EP5RY > kết_quả.txt 2>&1
```

### Xem device logs (trong terminal khác)

```bash
adb logcat
```

---

## 📁 HIỆN CÓ CÁC TEST FILES

```
integration_test/
├── app_test.dart          ← Main entry (chạy đầu tiên)
├── login_test.dart        ← 7 tests login
├── register_test.dart     ← 10 tests register
└── test_helpers.dart      ← Helper functions
```

---

## 🚀 NEXT STEPS

1. **Chạy test đầu tiên:**

   ```bash
   patrol test -t integration_test/app_test.dart -d RF8R32EP5RY
   ```

2. **Khi tests pass, thêm logic test:**

   - Mở `integration_test/login_test.dart`
   - Thêm code test vào
   - Chạy lại

3. **Integrate vào CI/CD:**
   - Add vào GitHub Actions / GitLab CI
   - Chạy tự động trên mỗi PR

---

## 💡 LƯU Ý

- **Lần đầu chậm (2-3 phút)** → lần sau nhanh hơn (30-60 giây)
- **Device cần bật & mở khóa** → bỏ qua sẽ fail
- **Network:** App cần internet khi test (hoặc mock API)

---

## 🎯 CHEAT SHEET

| Tác vụ          | Lệnh                                                              |
| --------------- | ----------------------------------------------------------------- |
| Chạy test       | `patrol test -t integration_test/app_test.dart -d RF8R32EP5RY`    |
| Kiểm tra device | `flutter devices`                                                 |
| Xem chi tiết    | `patrol test -t integration_test/app_test.dart -d RF8R32EP5RY -v` |
| Clean build     | `flutter clean`                                                   |
| Get deps        | `flutter pub get`                                                 |
| View logs       | `adb logcat`                                                      |

---

**SẴN SÀNG CHẠY TEST?** 🚀

```bash
cd /home/thao/Video_Al_App
patrol test -t integration_test/app_test.dart -d RF8R32EP5RY
```

Thành công! 💪
