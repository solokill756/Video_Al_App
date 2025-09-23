// Ví dụ cách sử dụng LoadingWidget trong app

import 'package:flutter/material.dart';
import 'loading_widget.dart';

class LoadingWidgetExamples extends StatelessWidget {
  const LoadingWidgetExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading Widget Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Loading Dialog
            const Text('1. Loading Dialog',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                context.showLoadingDialog(message: 'Đang tải...');
                Future.delayed(const Duration(seconds: 3), () {
                  context.hideLoadingDialog();
                });
              },
              child: const Text('Show Loading Dialog'),
            ),

            const SizedBox(height: 24),

            // 2. Loading Overlay
            const Text('2. Loading Overlay',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: LoadingOverlay(
                isLoading: true,
                message: 'Đang xử lý...',
                child: Container(
                  color: Colors.blue.shade50,
                  child: const Center(child: Text('Content bên dưới loading')),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 3. Loading Button
            const Text('3. Loading Button',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LoadingButton(
              isLoading: true,
              onPressed: () {},
              text: 'Đăng nhập',
              loadingText: 'Đang đăng nhập...',
            ),

            const SizedBox(height: 16),

            LoadingButton(
              isLoading: false,
              onPressed: () {},
              text: 'Đăng ký',
              backgroundColor: Colors.green,
            ),

            const SizedBox(height: 24),

            // 4. Different sizes
            const Text('4. Different Sizes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    LoadingWidget.small(showBackground: false),
                    Text('Small'),
                  ],
                ),
                Column(
                  children: [
                    LoadingWidget.medium(showBackground: false),
                    Text('Medium'),
                  ],
                ),
                Column(
                  children: [
                    LoadingWidget.large(showBackground: false),
                    Text('Large'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 5. With Message
            const Text('5. With Message',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const LoadingWidget.medium(
              message: 'Đang tải dữ liệu...',
              showBackground: false,
            ),

            const SizedBox(height: 24),

            // 6. Custom Loading
            const Text('6. Custom Loading',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomLoadingWidget(size: 24, color: Colors.red),
                CustomLoadingWidget(size: 32, color: Colors.blue),
                CustomLoadingWidget(size: 40, color: Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*
CÁCH SỬ DỤNG:

1. LOADING DIALOG:
```dart
// Hiển thị
context.showLoadingDialog(message: 'Đang tải...');

// Ẩn
context.hideLoadingDialog();
```

2. LOADING OVERLAY:
```dart
LoadingOverlay(
  isLoading: isLoading,
  message: 'Đang xử lý...',
  child: YourContentWidget(),
)
```

3. LOADING BUTTON:
```dart
LoadingButton(
  isLoading: _isLoading,
  onPressed: _handleSubmit,
  text: 'Đăng nhập',
  loadingText: 'Đang đăng nhập...',
)
```

4. SIMPLE LOADING WIDGET:
```dart
// Nhỏ cho button
LoadingWidget.small()

// Trung bình
LoadingWidget.medium(message: 'Đang tải...')

// Lớn cho toàn màn hình
LoadingWidget.large(message: 'Vui lòng đợi...')
```

5. CUSTOM LOADING:
```dart
CustomLoadingWidget(
  size: 40,
  color: Colors.blue,
  duration: Duration(milliseconds: 800),
)
```
*/
