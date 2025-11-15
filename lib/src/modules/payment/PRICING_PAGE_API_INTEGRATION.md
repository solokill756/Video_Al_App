# 🎯 PricingPage - Updated with Plan API Integration

## Summary

PricingPage đã được cập nhật để lấy danh sách gói dịch vụ từ **Plan API** thay vì hardcode dữ liệu.

---

## ✨ Key Changes

### ✅ Before (Hardcoded)

```dart
// Mock data trong initState
_plans = [
  PricingPlanData(id: null, name: 'FREE', ...),
  PricingPlanData(id: 1, name: 'BASIC', ...),
  PricingPlanData(id: 2, name: 'PREMIUM', ...),
];
```

### ✅ After (Dynamic from API)

```dart
// Load từ PlanCubit
void _loadPlans() {
  context.read<PlanCubit>().loadPlans(pageIndex: 1, pageSize: 100);
}

// Render dữ liệu từ API
BlocBuilder<PlanCubit, PlanState>(
  builder: (context, state) {
    return state.maybeWhen(
      plansLoaded: (plans) {
        final pricingPlans = _convertPlansToUi(plans);
        return Column(
          children: [...pricingPlans.map((plan) => _buildPricingCard(plan))],
        );
      },
    );
  },
)
```

---

## 🏗️ Integration Architecture

```
PricingPage
    ↓ (read)
PlanCubit.loadPlans()
    ↓
PlanRepository.getAllPlans()
    ↓
PlanApiService.getAllPlans()
    ↓
GET /plans
    ↓
Backend returns: List<Plan>
    ↓
Convert Plan → PricingPlanData
    ↓
UI renders pricing cards
```

---

## 📊 Data Flow

### 1. Load Plans

```dart
@override
void initState() {
  super.initState();
  _loadPlans();
}

void _loadPlans() {
  context.read<PlanCubit>().loadPlans(pageIndex: 1, pageSize: 100);
}
```

**PlanCubit emits state:**

- `Loading` → Show loading spinner
- `PlansLoaded` → Render cards
- `Error` → Show error message

### 2. Convert Models

```dart
List<PricingPlanData> _convertPlansToUi(List<Plan> plans) {
  // Sort: FREE first, then by price ascending
  final sortedPlans = plans
    ..sort((a, b) {
      if (a.price == 0) return -1; // FREE first
      if (b.price == 0) return 1;
      return a.price.compareTo(b.price);
    });

  // Map Plan model to UI PricingPlanData
  return sortedPlans.map((plan) {
    // Determine color, description, isPremium based on price
    Color color;
    String description;
    bool isPremium;

    if (plan.price == 0) {
      color = const Color(0xFF9CA3AF);
      description = 'Perfect for getting started';
      isPremium = false;
    } else if (plan.name.toUpperCase().contains('BASIC')) {
      color = const Color(0xFF0D9488);
      description = 'Great for creators';
      isPremium = true;
    } else {
      color = const Color(0xFF8B5CF6);
      description = 'For professional creators';
      isPremium = true;
    }

    // Extract features from plan.features map
    final List<String> features = [];
    plan.features.forEach((key, value) {
      if (value == true || (value is String && value.isNotEmpty)) {
        // Convert key: "max_videos" → "Max Videos"
        final feature = key
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
        features.add(feature);
      }
    });

    return PricingPlanData(
      id: plan.price == 0 ? null : plan.id,
      name: plan.name,
      price: '${plan.price.toStringAsFixed(0)} VND',
      description: description,
      features: features,
      color: color,
      isPremium: isPremium,
    );
  }).toList();
}
```

### 3. Render UI

```dart
BlocBuilder<PlanCubit, PlanState>(
  builder: (context, state) {
    return state.maybeWhen(
      loading: () => const CircularProgressIndicator(),
      plansLoaded: (plans) {
        final pricingPlans = _convertPlansToUi(plans);
        return Column(
          children: pricingPlans
              .map((plan) => _buildPricingCard(plan))
              .toList(),
        );
      },
      error: (message) => Container(
        // Show error UI
      ),
    );
  },
)
```

---

## 📦 Plan Model Structure

```dart
@freezed
class Plan {
  const factory Plan({
    required int id,
    required String planType,
    required String name,
    required String description,
    required double price,
    int? durationInDays,
    required Map<String, dynamic> features,  // Dynamic features!
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Plan;
}
```

### Features Map Example

```json
{
  "max_videos": 100,
  "max_resolution": "1080p",
  "has_watermark": false,
  "has_priority_support": true,
  "has_custom_branding": true,
  ...
}
```

---

## 🎨 UI Conversion Rules

### Color Assignment

- **FREE** (price = 0) → Gray (`0xFF9CA3AF`)
- **BASIC** (name contains "BASIC") → Teal (`0xFF0D9488`)
- **PREMIUM** (other) → Purple (`0xFF8B5CF6`)

### Price Formatting

- Backend: `99000` (number)
- UI: `"99,000 VND"` (formatted string)

### Features Extraction

- Backend key: `"max_videos"` (snake_case)
- UI text: `"Max Videos"` (title case)

### Plan Sorting

1. FREE plan first (price = 0)
2. Other plans by price ascending

---

## 🔄 States Handled

| State         | UI Behavior                           |
| ------------- | ------------------------------------- |
| `Loading`     | Show circular progress indicator      |
| `PlansLoaded` | Render pricing cards from plans list  |
| `Error`       | Show red error container with message |
| `Initial`     | Show nothing (empty)                  |

---

## 📝 Key Files

```
lib/src/modules/payment/presentation/page/
├─ pricing_page.dart ← UPDATED with Plan API integration
│  ├─ _loadPlans() → Trigger PlanCubit.loadPlans()
│  ├─ _convertPlansToUi() → Transform Plan → PricingPlanData
│  └─ _buildMainContent() → BlocBuilder for dynamic rendering
│
lib/src/modules/plan/presentation/application/cubit/
├─ plan_cubit.dart → loadPlans(pageIndex, pageSize)
├─ plan_state.dart → Loading, PlansLoaded, Error states
└─ plan_repository.dart → Interface
```

---

## ✅ Benefits

✅ **Dynamic Plans** - No need to update app for new plans  
✅ **Centralized Management** - Backend controls pricing  
✅ **Flexible Features** - Map-based features from API  
✅ **Automatic Sorting** - FREE first, then by price  
✅ **Error Handling** - Shows user-friendly error messages  
✅ **Loading States** - Loading indicator while fetching

---

## 🧪 Testing

### Test Case 1: Load Plans Successfully

1. Navigate to PricingPage
2. Verify loading spinner appears
3. API responds with plans
4. Verify plans render with correct data
5. Verify sorting (FREE first, then BASIC, PREMIUM)

### Test Case 2: API Error

1. Navigate to PricingPage
2. Backend returns error
3. Verify error message displayed
4. Verify user can retry

### Test Case 3: Features Extraction

1. Verify plan features display correctly
2. Verify snake_case keys converted to Title Case
3. Verify empty features fallback to default

---

## 🚀 Future Enhancements

- [ ] Add plan comparison feature
- [ ] Add discount badges
- [ ] Add "Most Popular" badge for top plan
- [ ] Add testimonials
- [ ] Add FAQ for each plan
- [ ] Add live pricing updates (real-time)

---

## 📞 Integration Checklist

- [x] PlanCubit imported
- [x] PlanState imported
- [x] BlocBuilder integrated
- [x] \_loadPlans() implemented
- [x] \_convertPlansToUi() implemented
- [x] \_buildMainContent() updated
- [x] Error handling added
- [x] Loading state handling
- [x] Feature extraction logic

---

**Last Updated:** November 14, 2025  
**Status:** ✅ Complete and Ready for Testing
