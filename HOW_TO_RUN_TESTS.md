# 🚀 Hướng dẫn chi tiết chạy Patrol E2E Tests

## ✅ Những gì đã được thiết lập

Bạn đã có:

- ✅ Patrol CLI cài đặt (v3.10.0)
- ✅ Dependencies cài đặt (`flutter pub get`)
- ✅ Android device kết nối: **SM A325F (API 33)**
- ✅ 17 test cases sẵn sàng

## 🔧 Setup lần đầu (nếu chạy session mới)

### 1. Cập nhật PATH (1 lần duy nhất)

```bash
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.bashrc
source ~/.bashrc
```

### 2. Kiểm tra Patrol

```bash
patrol --version
# Output: Patrol CLI version: 3.10.0 ✅
```

### 3. Kiểm tra device

```bash
flutter devices
# Output: SM A325F (mobile) • RF8R32EP5RY • android-arm64 • Android 13 (API 33) ✅
```

## 🧪 Chạy Tests

### Cách 1: Chạy tất cả tests

```bash
cd /home/thao/Video_Al_App
patrol test --target android
```

**Output dự kiến:**

- Tests sẽ chạy trên device SM A325F
- Mỗi test mất ~30-60 giây
- Total ~17 tests = ~8-10 phút

### Cách 2: Chạy login tests riêng

```bash
patrol test -t test_driver/login_test.dart --target android
```

### Cách 3: Chạy register tests riêng

```bash
patrol test -t test_driver/register_test.dart --target android
```

### Cách 4: Chạy test cụ thể

```bash
patrol test --target android --test 'User can login with valid credentials'
```

### Cách 5: Chạy với verbose mode (xem chi tiết)

```bash
patrol test --target android -v
```

## 📋 Các lệnh hữu ích

### Liệt kê tất cả tests

```bash
patrol test --target android --list
```

### Chạy tests và lưu kết quả

```bash
patrol test --target android > test_results.txt 2>&1
```

### Kiểm tra xem app build được không

```bash
flutter build apk --flavor dev
```

### Clean build & chạy lại

```bash
flutter clean
flutter pub get
patrol test --target android
```

## 🐛 Troubleshooting

### Error: "patrol: command not found"

**Solution:**

```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### Error: "No devices found"

**Solution:**

```bash
# Kiểm tra devices
flutter devices

# Nếu không có, kết nối Android device với USB
# Hoặc khởi động emulator
```

### Error: "Build failed"

**Solution:**

```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Tests timeout

**Solution - Chỉnh patrol.yaml:**

```yaml
testTimeout: 600000 # 10 phút thay vì 5 phút
```

### App crashes khi test

**Solution:**

- Kiểm tra `.env` file có đúng không
- Kiểm tra API_URL có reach được không
- Xem log: `adb logcat` khi test chạy

## 📱 Theo dõi tests trên device

Trong lúc tests chạy, bạn có thể:

1. Xem device screen để theo dõi interactions
2. Chạy `adb logcat` trong terminal khác để xem logs
3. Xem console output để theo dõi test progress

## ✨ Ví dụ chạy thực tế

```bash
$ cd /home/thao/Video_Al_App

# Setup (nếu session mới)
$ export PATH="$PATH":"$HOME/.pub-cache/bin"

# Kiểm tra
$ flutter devices
Found 1 connected devices:
  SM A325F (mobile) • RF8R32EP5RY • android-arm64 • Android 13 (API 33)

# Chạy tests
$ patrol test --target android

# Output:
# Running tests...
# Test 1: User can login with valid credentials ... ✅
# Test 2: User cannot login with invalid email ... ✅
# ...
# All tests passed! ✅
```

## 🎯 Next Steps

1. **Lần đầu tiên:**

   ```bash
   patrol test --target android
   ```

2. **Nếu có lỗi:**

   - Đọc error message
   - Kiểm tra device đang chạy app
   - Xem logs: `adb logcat`

3. **Khi tests pass:**
   - Thêm tests cho features khác
   - Tích hợp vào CI/CD

## 📞 Resources

- Test files: `/home/thao/Video_Al_App/test_driver/`
- Documentation: `/home/thao/Video_Al_App/test_driver/README.md`
- Full guide: `/home/thao/Video_Al_App/TEST_GUIDE.md`
- Quick ref: `/home/thao/Video_Al_App/QUICK_REFERENCE.md`

---

**Status**: ✅ Sẵn sàng chạy!  
**Device**: SM A325F (Android 13, API 33)  
**Tests**: 17 tests  
**Framework**: Patrol CLI v3.10.0
