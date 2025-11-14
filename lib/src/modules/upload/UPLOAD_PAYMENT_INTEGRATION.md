# 🎬 Upload + Payment Integration Guide

## Overview

Seamless integration between upload module and payment system. When users exceed their upload limit, they're presented with an upgrade prompt instead of just an error message.

## Flow Diagram

```
User attempts upload
        ↓
Upload limit exceeded
        ↓
limitExceeded state triggered in UploadCubit
        ↓
BlocListener in upload_video_page.dart detects state
        ↓
_showUpgradePlanModal() called
        ↓
PaymentCubit.getPaymentLink(planId: 3, planName: 'PREMIUM')
        ↓
Dialog opens with payment options
        ↓
User scans QR code and pays
        ↓
PaymentSuccess state received
        ↓
Dialog closes + Success message shown
        ↓
User can retry upload
```

## Implementation Details

### 1. **Imports Added**

```dart
import '../../../payment/presentation/application/cubit/payment_cubit.dart';
import '../../../payment/presentation/application/cubit/payment_state.dart';
import '../../../payment/presentation/components/payment_modal.dart';
```

### 2. **Updated limitExceeded Listener**

**Before:**

```dart
limitExceeded: (message) {
  AppDialogs.showSnackBar(
    message: message,
    backgroundColor: Colors.red,
  );
},
```

**After:**

```dart
limitExceeded: (message) {
  // Show payment modal to upgrade plan
  _showUpgradePlanModal(context, message);
},
```

### 3. **New \_showUpgradePlanModal() Method**

**Purpose:** Display payment modal when limit is exceeded

**Key Features:**

- Automatically fetches payment link for PREMIUM plan
- Wraps PaymentModal in BlocListener and BlocBuilder
- Handles multiple payment states:
  - `loading`: Shows loading spinner
  - `paymentLinkReceived`: Shows PaymentModal with QR code
  - `waitingForPayment`: Shows waiting spinner
  - `paymentSuccess`: Closes dialog + shows success message
  - `paymentError`: Shows error toast

**Code Structure:**

```dart
void _showUpgradePlanModal(BuildContext context, String limitMessage) {
  // 1. Get PaymentCubit
  final paymentCubit = context.read<PaymentCubit>();

  // 2. Set plan details (hardcoded to PREMIUM for upgrade)
  const planId = 3;
  const planName = 'PREMIUM';

  // 3. Trigger payment link fetch
  paymentCubit.getPaymentLink(planId: planId, planName: planName);

  // 4. Show dialog with payment modal
  showDialog(
    // MultiBlocListener for state changes
    // BlocBuilder to update UI based on payment state
  );
}
```

## User Experience Flow

### Scenario 1: User Exceeds Upload Limit

1. User uploads video → Limit exceeded
2. Modal appears: "Upgrade Your Plan"
3. User sees plan details and QR code
4. User scans QR and completes payment
5. Payment success → Dialog closes
6. Success message: "Plan upgraded successfully! You can now continue uploading."

### Scenario 2: Payment Fails

1. User sees payment modal
2. Payment fails (timeout, network error, etc.)
3. Error message shown: "Payment failed: [error]"
4. User can close modal and retry

### Scenario 3: User Closes Modal

1. User sees modal
2. Clicks outside dialog or Cancel button
3. `onClose()` callback triggers
4. `paymentCubit.cleanup()` called to disconnect socket
5. Modal closes

## State Management Flow

```
Initial State: UploadCubit.limitExceeded triggered
    ↓
PaymentCubit.initial()
    ↓ (getPaymentLink() called)
PaymentCubit.loading()
    ↓ (API returns registration link)
PaymentCubit.paymentLinkReceived(registrationLink, planId, planName)
    ↓ (modal opens, socket connects)
PaymentCubit.waitingForPayment(planId)
    ↓ (socket receives paymentSuccess event)
PaymentCubit.paymentSuccess(message, subscription)
    ↓ (dialog closes)
PaymentCubit.initial() (reset after 2-3 seconds)
```

## Important Notes

### Hardcoded Plan Selection

Currently, when user exceeds limit, they're offered **PREMIUM plan only**:

```dart
const planId = 3; // PREMIUM
const planName = 'PREMIUM';
```

**To support multiple plans:**

1. Extract plan ID from limitExceeded message
2. Parse message to determine which plan to suggest:
   - If Basic limit exceeded → Suggest Premium
   - If Premium limit exceeded → Suggest Enterprise (if exists)

### Dialog Dismissibility

Dialog is `barrierDismissible: true` - users can close by tapping outside. If this is not desired, change to `false`.

### Error Handling

Payment errors show a toast but keep modal open, allowing user to retry or close manually.

## Testing

### Manual Test Steps

1. **Setup:**

   - Ensure PaymentCubit is registered in main.dart ✅
   - Ensure PaymentModal component works ✅
   - Ensure UploadCubit has limitExceeded state ✅

2. **Test Limit Exceeded Trigger:**

   - Upload video normally (should succeed if within limit)
   - Upload additional videos until limit is hit
   - Verify limitExceeded state is triggered

3. **Test Modal Display:**

   - Verify dialog appears with PaymentModal
   - Verify QR code displays
   - Verify payment details show

4. **Test Payment Success:**

   - Complete payment in test
   - Verify "Plan upgraded successfully!" message
   - Verify dialog closes

5. **Test Payment Error:**
   - Simulate payment failure
   - Verify error message displays
   - Verify modal stays open

### Unit Test Example

```dart
testWidgets('Shows upgrade modal when limit exceeded', (WidgetTester tester) async {
  // Create upload cubit with limit state
  final uploadCubit = MockUploadCubit();
  final paymentCubit = MockPaymentCubit();

  // Build page with cubits
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<UploadCubit>.value(value: uploadCubit),
        BlocProvider<PaymentCubit>.value(value: paymentCubit),
      ],
      child: const MaterialApp(home: UploadVideoPage()),
    ),
  );

  // Trigger limit exceeded
  uploadCubit.emit(const UploadState.limitExceeded('Limit exceeded'));
  await tester.pumpAndSettle();

  // Verify dialog appears
  expect(find.byType(PaymentModal), findsOneWidget);
});
```

## Future Enhancements

1. **Dynamic Plan Selection**

   - Extract plan from error message
   - Suggest appropriate upgrade path

2. **Plan Comparison Modal**

   - Show all available plans before payment
   - Let user choose which plan to upgrade to

3. **Retry Upload After Success**

   - Add "Retry Upload" button in success message
   - Automatically retry previously failed upload

4. **Analytics**

   - Track when upgrade modal is shown
   - Track payment success rate
   - Track user abandonment rate

5. **Localization**
   - Support multiple languages
   - RTL language support

## Files Modified

- `/home/thao/Video_Al_App/lib/src/modules/upload/presentation/pages/upload_video_page.dart`
  - Added 3 imports (PaymentCubit, PaymentState, PaymentModal)
  - Changed limitExceeded listener to show modal
  - Added \_showUpgradePlanModal() method (90+ lines)

## Related Files

- `lib/src/modules/payment/presentation/application/cubit/payment_cubit.dart`
- `lib/src/modules/payment/presentation/application/cubit/payment_state.dart`
- `lib/src/modules/payment/presentation/components/payment_modal.dart`
- `lib/src/modules/payment/presentation/page/payment_test_page.dart`
