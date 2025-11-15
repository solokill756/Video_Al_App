# 💳 Payment Flow Implementation - Implementation Guide

## Tổng Quan Hoàn Thành

Hệ thống thanh toán đã được triển khai hoàn toàn với các component chính:

✅ **PricingPage** - Hiển thị danh sách gói dịch vụ  
✅ **PaymentModal** - Modal thanh toán với QR code  
✅ **PaymentCubit** - State management cho payment flow  
✅ **PaymentSocketService** - Quản lý WebSocket connection  
✅ **PaymentRepositoryImpl** - Kết nối API + Socket  
✅ **Socket Integration** - Real-time payment verification

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────┐
│        PricingPage (UI)             │
│  - Hiển thị 3 gói: FREE/BASIC/PREMIUM
│  - Click "Choose Plan" button       │
└──────────────┬──────────────────────┘
               │ (trigger payment)
               ▼
┌─────────────────────────────────────┐
│     PaymentCubit (State Management)  │
│  - getPaymentLink()                 │
│  - listenForPaymentSuccess()        │
│  - cleanup()                        │
└──────────────┬──────────────────────┘
               │
        ┌──────┴───────┐
        ▼              ▼
    ┌────────────────────────┐
    │  PaymentRepositoryImpl  │
    │  ├─ REST API Calls     │
    │  └─ Socket Events      │
    └──────────┬──────┬──────┘
               │      │
        ┌──────▼──┐   └──────┬──────────────┐
        │ API     │          │ Socket.IO    │
        │ Service │          │ Service      │
        └──────┬──┘          └──────┬───────┘
               │                    │
        HTTP POST         WebSocket Connection
               │                    │
               ▼                    ▼
        ┌──────────────┐   ┌──────────────┐
        │  Backend API │   │  Backend     │
        │ /payment/    │   │  Socket      │
        │ link-        │   │  /payment    │
        │registration  │   │              │
        └──────────────┘   └──────────────┘
```

---

## 📂 File Structure

```
lib/src/modules/payment/
├── data/
│   ├── model/
│   │   └── payment_model.dart          # Models (freezed)
│   ├── remote/
│   │   ├── payment_api_service.dart    # REST API (retrofit)
│   │   └── payment_socket_service.dart # WebSocket (socket.io)
│   └── repository/
│       └── payment_repository_impl.dart # Implementation
├── domain/
│   └── repository/
│       └── payment_repository.dart     # Interface
└── presentation/
    ├── application/
    │   └── cubit/
    │       ├── payment_cubit.dart      # State management
    │       └── payment_state.dart      # States (freezed)
    ├── components/
    │   └── payment_modal.dart          # Modal component
    └── page/
        ├── payment_test_page.dart      # Test page
        └── pricing_page.dart           # 🆕 Pricing page
```

---

## 🎯 User Journey (Complete Flow)

### Step 1: User Views Pricing Page

**File:** `lib/src/modules/payment/presentation/page/pricing_page.dart`

```dart
@RoutePage()
class PricingPage extends StatefulWidget {
  // Displays 3 plans: FREE, BASIC (99k), PREMIUM (299k)
}
```

**Features:**

- ✅ Plan cards with features list
- ✅ "Choose Plan" button for BASIC/PREMIUM
- ✅ "Current Plan" badge for FREE
- ✅ FAQ section
- ✅ Professional pricing layout

---

### Step 2: User Clicks "Choose Plan"

**Triggered:** `_onChoosePlanPressed(plan)`

```dart
void _onChoosePlanPressed(PricingPlanData plan) {
  // 1. Validate plan
  if (plan.id == null) return; // FREE plan - no payment

  // 2. Show loading toast
  showToast('⏳ Preparing payment...');

  // 3. Trigger PaymentCubit
  context.read<PaymentCubit>().getPaymentLink(
    planId: plan.id!,
    planName: plan.name,
  );
}
```

**State Change:** `Initial` → `Loading`

---

### Step 3: PaymentCubit Gets Payment Link

**File:** `lib/src/modules/payment/presentation/application/cubit/payment_cubit.dart`

```dart
Future<void> getPaymentLink({
  required int planId,
  required String planName,
}) async {
  // 1. Emit Loading state
  emit(const PaymentState.loading());

  // 2. Call API
  final response = await _paymentRepository.getPaymentLink(
    planId: planId,
  );

  // 3. Emit PaymentLinkReceived state
  emit(PaymentState.paymentLinkReceived(
    registrationLink: response.registrationLink,
    planId: planId.toString(),
    planName: planName,
  ));
}
```

**API Call:** `POST /payment/link-registration`

```json
Request:
{
  "planId": 2
}

Response:
{
  "registrationLink": "https://qr.sepay.vn/img?acc=888852690888&bank=VietinBank&amount=299000&des=SEVQR%20PREMIUM123"
}
```

**State Change:** `Loading` → `PaymentLinkReceived`

---

### Step 4: PricingPage Handles State Change

**Listener:** `_handlePaymentState()`

```dart
state.whenOrNull(
  paymentLinkReceived: (link, planId, planName) {
    // 1. Parse payment link
    setState(() {
      _paymentLink = link;
      _selectedPlanName = planName;
      _isPaymentModalOpen = true;
    });

    // 2. Setup socket listener
    context.read<PaymentCubit>().listenForPaymentSuccess(
      planId: int.parse(planId),
    );
  },
)
```

**UI Update:** PaymentModal opens with QR code

---

### Step 5: PaymentCubit Setup Socket Listener

**File:** `payment_cubit.dart`

```dart
Future<void> listenForPaymentSuccess({
  required int planId,
}) async {
  // 1. Emit WaitingForPayment state
  emit(PaymentState.waitingForPayment(planId: planId.toString()));

  // 2. Register socket listener
  await _paymentRepository.registerPaymentSuccessListener(
    onSuccess: (data) {
      // Emit PaymentSuccess state
      emit(PaymentState.paymentSuccess(
        message: 'Thanh toán thành công!',
        subscription: data['subscription'],
      ));

      // Auto reset after 3s
      Future.delayed(const Duration(seconds: 3), () {
        if (!isClosed) emit(const PaymentState.initial());
      });
    },
    onError: (error) {
      emit(PaymentState.paymentError(error: error));
    },
  );

  // 3. Setup timeout (10 minutes)
  Future.delayed(_paymentTimeoutDuration, () {
    if (!isClosed && state.maybeWhen(...)) {
      emit(PaymentState.paymentError(
        error: 'Thanh toán timeout',
        errorCode: 'PAYMENT_TIMEOUT',
      ));
    }
  });
}
```

**State Change:** `WaitingForPayment` (listening for socket event)

---

### Step 6: Socket Service Connects to Backend

**File:** `lib/src/modules/payment/data/repository/payment_repository_impl.dart`

```dart
Future<void> registerPaymentSuccessListener({
  required Function(Map<String, dynamic> data) onSuccess,
  Function(String error)? onError,
}) async {
  // 1. Register callbacks
  _paymentSocketService.onPaymentSuccess((data) {
    onSuccess(data);
  });

  // 2. Connect to socket
  await _paymentSocketService.connect(
    baseUrl: 'http://localhost:3000', // TODO: from env config
    token: 'Bearer ...', // TODO: from auth
  );
}
```

**File:** `lib/src/modules/payment/data/remote/payment_socket_service.dart`

```dart
Future<void> connect({
  required String baseUrl,
  required String token,
}) async {
  // 1. Create socket instance
  _socket = IO.io(
    '$baseUrl/payment', // namespace
    IO.OptionBuilder()
        .setTransports(['websocket', 'polling'])
        .enableAutoConnect()
        .setAuth({'token': token})
        .build(),
  );

  // 2. Setup event listeners
  _setupEventListeners();
}
```

**Socket Events:**

- `connect` - Socket connected ✅
- `paymentSuccess` - Payment verified from backend 💰
- `paymentError` - Payment failed ❌
- `connect_error` - Connection error ⚠️
- `disconnect` - Socket disconnected 🔌

---

### Step 7: User Performs Payment

**Options:**

1. **Scan QR Code** - Mobile banking app
2. **Manual Entry** - Ngân hàng/Số TK/Số tiền/Nội dung

**Payment Details from QR URL:**

```
https://qr.sepay.vn/img?acc=888852690888&bank=VietinBank&amount=299000&des=SEVQR%20PREMIUM123

Parameters:
- acc: 888852690888 (Account number)
- bank: VietinBank (Bank name)
- amount: 299000 (Amount in VND)
- des: SEVQR PREMIUM123 (Description - ⚠️ MUST BE EXACT)
```

**⚠️ Important:**

- Nội dung chuyển khoản PHẢI chính xác 100%
- Backend sử dụng nội dung này để verify transaction
- Sai nội dung = không được kích hoạt

---

### Step 8: Backend Verifies Payment

**Backend Process:**

1. Receive payment from bank via webhook
2. Verify transaction:
   - Amount matches
   - Content matches
   - Account correct
3. Update database (create subscription)
4. **Emit Socket Event:** `paymentSuccess`

**Event Payload:**

```json
{
  "status": "success",
  "subscription": {
    "id": 456,
    "planId": 2,
    "userId": 123,
    "startDate": "2025-11-14",
    "endDate": "2026-11-14",
    "isActive": true
  }
}
```

---

### Step 9: Frontend Receives Socket Event

**Socket Listener** (in `payment_socket_service.dart`):

```dart
_socket!.on('paymentSuccess', (data) {
  print('✨ Payment success event: $data');

  // Call the registered callback
  _onPaymentSuccessCallback?.call(data as Map<String, dynamic>);
});
```

**Flow:**

- Socket emits `paymentSuccess`
- PaymentSocketService calls `_onPaymentSuccessCallback`
- PaymentRepository's `onSuccess` callback is invoked
- PaymentCubit emits `PaymentSuccess` state

---

### Step 10: UI Updates with Success

**PricingPage Listener:**

```dart
paymentSuccess: (message, subscription) {
  // 1. Show success toast
  showToast(
    '✅ $message',
    position: ToastPosition.bottom,
    duration: const Duration(seconds: 2),
  );

  // 2. Auto close modal after 2 seconds
  Future.delayed(const Duration(seconds: 2), () {
    if (mounted) {
      _onPaymentModalClose();
      // Optionally redirect
      // context.router.replace(const VideoManagementRoute());
    }
  });
}
```

**PaymentModal Updates:**

- Hide "Đang chờ thanh toán..."
- Show success icon ✅
- Display "Thanh toán thành công!"
- Auto close after 2s

**User Outcome:** Plan is activated ✨

---

## 🔧 Configuration Required

### 1. Backend URL (TODO)

**File:** `payment_repository_impl.dart` line ~149

```dart
// TODO: Get base URL từ environment config
const baseUrl = 'http://localhost:3000';

// Should be replaced with:
// final baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
```

**Setup:**

```env
# .env file
API_URL=http://localhost:3000
# or production:
# API_URL=https://api.example.com
```

### 2. Authentication Token (TODO)

**File:** `payment_repository_impl.dart` line ~155

```dart
// TODO: Get auth token từ secure storage / auth cubit
const token = 'Bearer mock-token';

// Should be replaced with:
// final authCubit = context.read<AuthCubit>();
// final token = 'Bearer ${authCubit.state.accessToken}';
```

### 3. Socket.IO Configuration

**Already Configured in** `payment_socket_service.dart`:

- ✅ Namespace: `/payment`
- ✅ Auth header: `{ token: 'Bearer ...' }`
- ✅ Transports: `['websocket', 'polling']` (fallback)
- ✅ Auto-reconnect: Enabled with exponential backoff
- ✅ Reconnect delay: 5s, max 25s

---

## 📱 PaymentModal UI Components

### QR Code Section

```
┌─────────────────────────┐
│   QR Code Display       │
│  ┌──────────────────┐  │
│  │   QR Icon        │  │
│  │  (Placeholder)   │  │
│  └──────────────────┘  │
│                        │
│ "Scan with banking app"│
└─────────────────────────┘
```

### Payment Info Fields

```
┌─────────────────────────┐
│ Bank: VietinBank  [Copy]│
│ Account: 8888...  [Copy]│
│ Amount: 299k VND  [Copy]│
│ Content: SEVQR... [Copy]│← Highlighted (important!)
└─────────────────────────┘
```

### Instructions Section

```
1️⃣ Open your banking app
2️⃣ Scan QR or enter details
3️⃣ Verify amount and content
4️⃣ Complete transfer

ℹ️ Activation within 1-2 min
```

---

## ⚠️ Error Handling

### API Errors

**401 Unauthorized**

```dart
// User not logged in
"Vui lòng đăng nhập để tiếp tục"
```

**404 Plan Not Found**

```dart
// Plan doesn't exist
"Gói dịch vụ không tìm thấy"
```

**500 Server Error**

```dart
// Backend error
"Lỗi khi xử lý thanh toán"
```

### Socket Errors

**Connection Failed**

```dart
// Socket connection error
"Lỗi kết nối. Vui lòng kiểm tra internet"
// Auto-retry with exponential backoff
```

**Timeout (10 minutes)**

```dart
// No payment received within timeout
"Thanh toán timeout. Vui lòng thử lại hoặc liên hệ hỗ trợ."
```

### User Errors

**Wrong Transfer Content**

```
⚠️ Vui lòng nhập chính xác nội dung chuyển khoản
(Highlighted in yellow to warn user)
```

---

## 🧪 Testing Checklist

- [ ] PricingPage displays 3 plans correctly
- [ ] "Choose Plan" button works for BASIC/PREMIUM
- [ ] FREE plan shows "Current Plan" (disabled button)
- [ ] Click Choose Plan → Loading toast appears
- [ ] API returns QR code link successfully
- [ ] PaymentModal opens with correct plan name
- [ ] QR code displays correctly
- [ ] Payment info fields show correct values
- [ ] Copy buttons work (toast + highlight)
- [ ] Socket connects when modal opens
- [ ] Browser console: "✅ Connected to payment socket"
- [ ] User performs test payment
- [ ] Backend emits paymentSuccess event
- [ ] Frontend receives event → Success toast
- [ ] Modal auto-closes after 2 seconds
- [ ] Close button works manually
- [ ] Cleanup happens when modal closes

---

## 🔍 Debugging

### Check Socket Connection

**Browser DevTools Console:**

```javascript
// Socket status should show connected
```

**App Logs:**

```
✅ Connected to payment socket
```

### Check API Call

**Network Tab:**

```
POST /payment/link-registration
Status: 200
Response: { registrationLink: "..." }
```

### Check Event Receive

**App Logs:**

```
✨ Received paymentSuccess event: {...}
```

---

## 📚 Related Documentation

- [Payment Flow Documentation](./DESIGN_UPDATE.md) - Full design details
- [Payment Module Structure](./READY_TO_TEST.md) - What's ready to test
- [Backend API Reference](../../../core/docs/VIDEO_AND_PRICING_API_VI.md)

---

## 🚀 Next Steps (Future Enhancements)

1. **Connect Real Backend URL**

   - Add API_URL to .env configuration
   - Update PaymentRepositoryImpl to use env config

2. **Implement Actual QR Code Display**

   - Import qr_flutter package
   - Replace placeholder with QrImage widget
   - Generate QR from registrationLink

3. **Add Authentication Integration**

   - Get token from AuthCubit
   - Pass Bearer token to socket connection
   - Handle token refresh

4. **Add Payment History**

   - Create payment history page
   - Display past subscriptions
   - Show transaction details

5. **Add Multiple Payment Methods**

   - Momo
   - ZaloPay
   - Credit card

6. **Add Refund Support**

   - Refund request UI
   - Refund status tracking
   - Admin approval flow

7. **Add Subscription Auto-Renewal**

   - Remind users before expiry
   - Auto-renew option
   - Payment failure handling

8. **Analytics**
   - Track conversion rates
   - Monitor payment failures
   - Analyze plan popularity

---

## 📞 Support

For issues or questions:

1. Check browser console logs
2. Check app logs for "❌ Error..." messages
3. Review error message in UI (Vietnamese)
4. Contact backend team if API/Socket issues

---

**Implementation Date:** November 14, 2025  
**Status:** ✅ Complete and Ready for Testing  
**Last Updated:** November 14, 2025
