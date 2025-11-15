# 🚀 HƯỚNG DẪN NHANH - CHẠY E2E TESTS

## ✅ ĐÃ CHUẨN BỊ

- ✓ Appium 2.0.1
- ✓ Python 3.12.3
- ✓ Android device: Samsung SM-A325F (RF8R32EP5RY)
- ✓ App package: com.fau.dmvgenie
- ✓ Dependencies đã cài trong venv

---

## 📝 CHẠY TESTS - 3 BƯỚC ĐƠN GIẢN

### 🔴 TERMINAL 1: Khởi động Appium

```bash
appium
```

**⚠️ Để terminal này chạy, KHÔNG TẮT!**

---

### 🔵 TERMINAL 2: Chạy Tests

#### Bước 1: Vào thư mục và kích hoạt venv

```bash
cd /home/thao/Video_Al_App/appium_test
source venv/bin/activate
cd test_cases
```

#### Bước 2: Chọn 1 trong các lệnh sau để chạy

**A. TEST DEMO (Recommended - Kiểm tra kết nối):**

```bash
python3 demo_test.py
```

⏱️ Thời gian: ~10 giây  
📝 Mô tả: Kiểm tra kết nối Appium, khởi động app, chụp screenshot

---

**B. LOGIN TESTS (8 tests):**

```bash
python3 test_login.py
```

⏱️ Thời gian: ~10 phút  
📝 Tests:

- Hiển thị login page
- Login với thông tin hợp lệ
- Login với email không hợp lệ
- Login với email/password trống
- Login với password sai
- Navigate đến register/forgot password

---

**C. REGISTER TESTS (9 tests):**

```bash
python3 test_register.py
```

⏱️ Thời gian: ~10 phút  
📝 Tests:

- Hiển thị register page
- Nhập email và continue
- Validate email
- Complete registration flow
- Validate OTP
- Password mismatch
- Resend OTP

---

**D. TẤT CẢ TESTS (17 tests):**

```bash
python3 run_all_tests.py
```

⏱️ Thời gian: ~20 phút  
📝 Chạy toàn bộ Login + Register tests

---

## 🎯 HOẶC SỬ DỤNG SCRIPT TỰ ĐỘNG (DễNHẤT!)

```bash
cd /home/thao/Video_Al_App/appium_test
./quick_start.sh
```

Script tự động:

- ✅ Kiểm tra Appium server
- ✅ Kiểm tra thiết bị
- ✅ Kích hoạt venv
- ✅ Menu chọn test

---

## 📊 KẾT QUẢ TEST

### ✅ Khi Pass:

```
test_01_login_page_displayed ... ok
test_02_login_with_valid_credentials ... ok
...
----------------------------------------------------------------------
Ran 8 tests in 245.123s
OK
```

### ❌ Khi Fail:

- Screenshot tự động lưu: `test_cases/screenshots/`
- Xem log chi tiết để debug

---

## 🔧 LỆNH HỮU ÍCH

### Kiểm tra thiết bị:

```bash
adb devices
```

### Kiểm tra Appium:

```bash
curl http://127.0.0.1:4723/status
```

### Install app:

```bash
cd /home/thao/Video_Al_App
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

### Uninstall app:

```bash
adb uninstall com.fau.dmvgenie
```

### Clear app data:

```bash
adb shell pm clear com.fau.dmvgenie
```

### Xem logs:

```bash
adb logcat | grep -i flutter
```

---

## 🐛 KHI GẶP LỖI

### "Connection Refused"

➡️ Appium chưa chạy → Chạy `appium` ở Terminal 1

### "No devices"

➡️ Thiết bị bị mất → Chạy `adb devices` để kiểm tra

### "Module not found"

➡️ Chưa activate venv → Chạy `source venv/bin/activate`

### "Element not found"

➡️ App load chậm → Tăng timeout trong `test_config.py`

---

## 🎬 BẮT ĐẦU NHANH

**Lệnh nhanh nhất để test ngay:**

```bash
# Terminal 1
appium

# Terminal 2 (trong tab mới)
cd /home/thao/Video_Al_App/appium_test && source venv/bin/activate && cd test_cases && python3 demo_test.py
```

Sau khi demo_test chạy OK, chạy test thật:

```bash
python3 test_login.py
```

---

## 📚 TÀI LIỆU

- Chi tiết: `HUONG_DAN_CHAY_TEST.md`
- Full docs: `README.md`
- Quick ref: `QUICK_START.md`

---

**🚀 GOOD LUCK TESTING!**
