# ⚡ Quick Reference - Payment Flow

## Files Created/Modified

### 🆕 NEW Files

- `pricing_page.dart` - Main pricing page with 3 plans

### ✏️ UPDATED Files

- `payment_socket_service.dart` - Full socket.io implementation
- `payment_repository_impl.dart` - Socket integration
- `payment_modal.dart` - Socket setup methods

---

## Key Classes

### PricingPage

```dart
// Navigate to pricing
context.router.push(const PricingRoute());

// Handle plan selection
onChoosePlanPressed(plan) {
  context.read<PaymentCubit>().getPaymentLink(...);
}
```

### PaymentCubit

```dart
// Get payment link
await paymentCubit.getPaymentLink(planId: 2, planName: "PREMIUM");

// Listen for payment success
await paymentCubit.listenForPaymentSuccess(planId: 2);

// Cleanup
await paymentCubit.cleanup();
```

### PaymentSocketService

```dart
// Connect
await service.connect(baseUrl: "...", token: "Bearer ...");

// Register callbacks
service.onPaymentSuccess((data) => ...);
service.onPaymentError((error) => ...);

// Disconnect
await service.disconnect();

// Check status
if (service.isConnected) { ... }
```

---

## API Flow

### 1. Get Payment Link

```
POST /payment/link-registration
Headers: Authorization: Bearer {token}
Body: { planId: 2 }
Response: { registrationLink: "https://qr.sepay.vn/img?..." }
```

### 2. Socket Connection

```
Namespace: /payment
Auth: { token: "Bearer ..." }
Events:
  - paymentSuccess: { status: "success", subscription: {...} }
  - paymentError: "Error message"
  - connect_error: "Connection error"
  - disconnect: "Reason"
```

---

## State Flow

```
Initial
  ↓ (click Choose Plan)
Loading
  ↓ (API returns)
PaymentLinkReceived
  ↓ (modal opens, socket connects)
WaitingForPayment
  ↓ (receive paymentSuccess event)
PaymentSuccess
  ↓ (auto close modal)
Initial
```

---

## UI Components

### PricingPage

```dart
- Header with title
- 3 plan cards (FREE/BASIC/PREMIUM)
- FAQ section
- Responsive layout
```

### PaymentModal

```dart
- QR code display
- Payment info fields (Bank, Account, Amount, Description)
- Copy buttons
- Instructions
- Loading/Success/Error states
```

---

## Environment Setup (TODO)

### 1. Add .env

```env
API_URL=http://localhost:3000
```

### 2. Update payment_repository_impl.dart

```dart
final baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
```

### 3. Add auth integration

```dart
final token = 'Bearer ${authCubit.state.accessToken}';
```

### 4. Implement QR display

```dart
// In payment_modal.dart _buildQRCodeWidget()
import 'package:qr_flutter/qr_flutter.dart';
return QrImage(data: _paymentInfo.qrUrl);
```

---

## Testing Checklist

- [ ] PricingPage displays correctly
- [ ] Click "Choose Plan" shows loading
- [ ] PaymentModal opens after API response
- [ ] QR code displays (placeholder or real)
- [ ] Payment info shows correctly
- [ ] Copy buttons work + show toast
- [ ] Socket connects (check console)
- [ ] Can close modal without error
- [ ] Cleanup happens on dispose

---

## Common Issues

| Issue                  | Solution                                |
| ---------------------- | --------------------------------------- |
| Socket not connecting  | Check backend URL, verify token         |
| QR code not showing    | Replace placeholder with QrImage        |
| Payment not activating | Verify transfer description exact match |
| Modal doesn't close    | Check PaymentCubit cleanup() called     |

---

## Package Dependencies

```yaml
dependencies:
  socket_io_client: ^2.0.2
  qr_flutter: ^4.1.0
  flutter_bloc: ^9.0.0
  freezed_annotation: ^2.4.1
  retrofit: ^4.1.0
```

---

**Last Updated:** November 14, 2025  
**Status:** ✅ Complete
