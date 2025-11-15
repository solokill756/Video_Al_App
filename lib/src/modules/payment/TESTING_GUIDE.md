# 🧪 Payment Module - Testing Guide

## ✅ Setup Hoàn Tất!

Payment Module đã được integrate vào app. Bạn có thể test ngay bây giờ!

## 🚀 Cách Test

### Step 1: Start App

```bash
flutter run
```

### Step 2: Navigate to Test Page

**Option A: Từ Home Page**

1. Mở app
2. Nhìn góc dưới bên phải
3. Bấm floating button **"Test Payment"** (màu tím)

**Option B: Direct Navigation**

```dart
context.router.pushNamed('/payment-test');
```

**Option C: URL (nếu dùng web)**

```
http://localhost:PORT/payment-test
```

### Step 3: Click Subscribe

1. Trên Payment Test Page, bạn sẽ thấy 3 gói:

   - **FREE** (0 VND) - Không có nút subscribe
   - **BASIC** (99,000 VND) - Có nút "Nâng Cấp"
   - **PREMIUM** (299,000 VND) - Có nút "Nâng Cấp"

2. Click nút **"Nâng Cấp"** trên BASIC hoặc PREMIUM

3. Nếu backend đang chạy:

   - ✅ Payment Modal sẽ hiển thị
   - ✅ QR code placeholder xuất hiện
   - ✅ Payment details hiển thị (Bank, Account, Amount, Description)
   - ✅ Copy buttons hoạt động

4. Nếu backend KHÔNG chạy:
   - ❌ Hiển thị error: "Lỗi kết nối..."
   - Bạn có thể retry sau khi start backend

### Step 4: Test Payment Flow

#### A. Test với Backend Thật

**Requirements:**

- Backend API running at configured URL
- Endpoint: `POST /payment/link-registration`
- Socket.IO server running on `/payment` namespace

**Flow:**

1. Click Subscribe
2. Backend trả về QR link
3. Modal hiển thị QR code + payment details
4. User quét QR code bằng mobile banking app
5. User confirm payment
6. Backend nhận payment từ SePayVN
7. Backend emit `paymentSuccess` event qua socket
8. Frontend nhận event
9. Hiển thị success screen
10. Auto close + redirect (optional)

#### B. Test Copy Buttons

1. Modal đang mở
2. Click [Copy] button bên cạnh:
   - Ngân hàng
   - Số tài khoản
   - Số tiền
   - Nội dung chuyển khoản (QUAN TRỌNG - highlighted)
3. Toast hiển thị: "✅ Đã copy [field name]"
4. Field highlight màu vàng trong 2 giây
5. Paste anywhere để verify

#### C. Test Close Modal

1. Modal đang mở
2. Click nút X ở góc trên
3. Modal đóng
4. Console log: "🧹 Cleaning up payment resources..."
5. Socket disconnect (nếu đã connect)
6. State reset về Initial

#### D. Test Error Handling

**Network Error:**

1. Stop backend
2. Click Subscribe
3. Expected: Toast "❌ Lỗi kết nối..."

**Timeout (10 minutes):**

1. Open modal
2. Wait 10 minutes (hoặc modify timeout constant)
3. Expected: Auto error "⏱️ Thanh toán timeout..."

**Socket Error:**

1. Backend không có Socket.IO
2. Modal opens nhưng socket fail
3. Expected: Error message

### Step 5: Check Console Logs

Mở DevTools console để xem logs:

```
✅ Subscribe pressed: BASIC (ID: 1)
📝 Getting payment link for plan: BASIC (ID: 1)
✅ Payment link received: https://qr.sepay.vn/img?...
⏳ Waiting for payment confirmation...
✨ Payment success received: {...}
🎉 Payment success state emitted
🧹 Cleaning up payment resources...
✅ Cleanup completed
```

---

## 🎨 UI Features

### Payment Test Page

**Top Section:**

- Tiêu đề: "💳 Chọn Gói Dịch Vụ"
- Subtitle: Test instruction

**Plan Cards:**

- FREE card (grey) - No subscribe button
- BASIC card (blue) - "Nâng Cấp" button
- PREMIUM card (purple) - "Nâng Cấp" button

Each card shows:

- Plan name
- Price
- Feature list với checkmark icons
- Subscribe button (nếu không phải FREE)

**Test Controls Section (Orange box):**

- Mock Success button (disabled - need real backend)
- Mock Error button (disabled - need real backend)
- Reset State button (active)

### Payment Modal

**Header:**

- "Thanh toán gói [PLAN_NAME]"
- X button to close

**Content:**

- QR Code section (placeholder với URL text)
- Payment Info section:
  - Ngân hàng + [Copy]
  - Số tài khoản + [Copy]
  - Số tiền + [Copy]
  - Nội dung chuyển khoản + [Copy] (highlighted orange)
- Instructions section (4 steps)

**States:**

- Loading: Spinner
- PaymentLinkReceived: Full modal with QR + details
- WaitingForPayment: "⏳ Chờ xác nhận thanh toán..."
- Success: ✅ icon + "🎉 Thanh toán thành công!"
- Error: ❌ icon + error message + Retry button

---

## 🔧 Configuration

### Update Backend URL

**File: `lib/src/common/utils/app_environment.dart`**

Hoặc nơi bạn configure Dio baseUrl:

```dart
// Update để point tới backend của bạn
final dio = Dio(BaseOptions(
  baseUrl: 'http://localhost:3000', // ← Thay đổi này
));
```

### Update Socket URL

**File: `lib/src/modules/payment/data/remote/payment_socket_service.dart`**

```dart
void initialize({
  required String socketUrl, // ← Cần pass URL này khi initialize
  required String token,
}) {
  _socketUrl = socketUrl;
  _token = token;
}
```

---

## 📝 Backend Requirements

### API Endpoint

```
POST /payment/link-registration

Headers:
  Authorization: Bearer {token}

Body:
{
  "planId": 1
}

Response:
{
  "registrationLink": "https://qr.sepay.vn/img?acc=888852690888&bank=VietinBank&amount=99000&des=SEVQR%20PAYMENT"
}
```

### Socket.IO Event

```javascript
// Backend emit khi payment success
io.of('/payment').emit('paymentSuccess', {
  status: 'success',
  subscription: {
    planId: 1,
    planName: 'BASIC',
    expiresAt: '2025-12-13',
  },
  message: 'Thanh toán thành công!',
});
```

---

## ✅ Checklist

**Setup:**

- [x] PaymentCubit added to BlocProvider (main.dart)
- [x] PaymentTestPage created
- [x] Route registered (/payment-test)
- [x] Floating button added to HomePage
- [x] Build runner executed

**Testing:**

- [ ] App starts without errors
- [ ] Navigate to Payment Test Page
- [ ] Click Subscribe button
- [ ] Modal appears (with or without backend)
- [ ] Copy buttons work
- [ ] Close button works
- [ ] Error handling works
- [ ] No console errors

**Backend Integration:**

- [ ] Backend API /payment/link-registration returns QR link
- [ ] Socket.IO server running
- [ ] Socket emits paymentSuccess event
- [ ] Frontend receives socket event
- [ ] Success flow completes

---

## 🐛 Troubleshooting

| Issue                         | Solution                                              |
| ----------------------------- | ----------------------------------------------------- |
| Can't find payment-test route | Run `flutter pub run build_runner build`              |
| PaymentCubit not found        | Check main.dart BlocProvider                          |
| Modal doesn't show            | Check console for API errors                          |
| Copy button not working       | Verify oktoast is in pubspec.yaml                     |
| Socket not connecting         | Implement socket_io_client (see INTEGRATION_GUIDE.md) |

---

## 📚 Documentation

Đọc thêm chi tiết:

1. **HOW_TO_USE.md** - Hướng dẫn sử dụng chi tiết
2. **FLOW_DIAGRAM.md** - Visual diagrams
3. **STEP_BY_STEP.md** - Integration examples
4. **CHEAT_SHEET.md** - Quick reference
5. **INTEGRATION_GUIDE.md** - Backend integration

---

## 🎉 Ready to Test!

```bash
# Start app
flutter run

# Or with specific device
flutter run -d chrome
flutter run -d android
flutter run -d ios
```

**Happy Testing! 🚀**
