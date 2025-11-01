import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// --- ENUM VÀ CÁC WIDGET PUBLIC ---

/// Các kiểu loading animation khác nhau.
enum LoadingType { circular, dots, pulse, spinner, wave, gear }

/// Widget loading dùng chung, linh hoạt và có thể tùy chỉnh cho toàn bộ ứng dụng.
///
/// Widget này chỉ chịu trách nhiệm hiển thị animation và tin nhắn.
/// Nó không bao gồm nền mờ hay hộp chứa màu trắng.
class LoadingWidget extends StatelessWidget {
  /// Tin nhắn hiển thị bên dưới animation.
  final String? message;

  /// Kích thước của animation.
  final double? size;

  /// Màu sắc của animation.
  final Color? color;

  /// Kiểu animation để hiển thị.
  final LoadingType type;

  const LoadingWidget({
    super.key,
    this.message,
    this.size,
    this.color,
    this.type = LoadingType.circular,
  });

  /// Constructor tiện lợi cho loading indicator nhỏ, thường dùng trong button.
  const LoadingWidget.small({
    super.key,
    this.message,
    this.color,
    this.type = LoadingType.circular,
  }) : size = 20;

  /// Constructor tiện lợi cho loading indicator trung bình.
  const LoadingWidget.medium({
    super.key,
    this.message,
    this.color,
    this.type = LoadingType.dots,
  }) : size = 32;

  /// Constructor tiện lợi cho loading indicator lớn, thường dùng cho toàn màn hình.
  const LoadingWidget.large({
    super.key,
    this.message,
    this.color,
    this.type = LoadingType.pulse,
  }) : size = 48;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).primaryColor;
    final effectiveSize = (size ?? 32.0).w;

    Widget loadingIndicator = _buildLoadingByType(
      effectiveColor,
      effectiveSize,
    );

    // Nếu có tin nhắn, bọc animation trong một Column
    if (message != null && message!.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          loadingIndicator,
          SizedBox(height: 16.h),
          Text(
            message!,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return loadingIndicator;
  }

  /// Xây dựng widget animation dựa trên `LoadingType`.
  Widget _buildLoadingByType(Color color, double size) {
    switch (type) {
      case LoadingType.circular:
        return _CircularLoader(color: color, size: size);
      case LoadingType.dots:
        return _DotsLoader(color: color, size: size);
      case LoadingType.pulse:
        return _PulseLoader(color: color, size: size);
      case LoadingType.spinner:
        return _SpinnerLoader(color: color, size: size);
      case LoadingType.wave:
        return _WaveLoader(color: color, size: size);
      case LoadingType.gear:
        return _GearLoader(color: color, size: size);
    }
  }
}

/// Một lớp phủ (overlay) hiển thị loading trên toàn bộ một widget con.
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;
  final LoadingType loadingType;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
    this.loadingType = LoadingType.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.4),
            child: Center(
              child: LoadingWidget.large(message: message, type: loadingType),
            ),
          ),
      ],
    );
  }
}

/// Button có trạng thái loading tích hợp.
class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String text;
  final String? loadingText;
  final ButtonStyle? style;
  final LoadingType loadingType;
  final Color? backgroundColor;
  final Color? textColor;

  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
    this.loadingText,
    this.style,
    this.loadingType = LoadingType.circular,
    this.backgroundColor = const Color(0xFF0D9488),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = style ??
        ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          minimumSize: Size.fromHeight(52.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: isLoading
            ? Row(
                key: const ValueKey('loading_btn'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingWidget.small(
                    color: buttonStyle.foregroundColor?.resolve({}) ??
                        Colors.white,
                    type: loadingType,
                  ),
                  if (loadingText != null && loadingText!.isNotEmpty) ...[
                    SizedBox(width: 12.w),
                    Text(loadingText!),
                  ],
                ],
              )
            : Text(text, key: const ValueKey('text_btn')),
      ),
    );
  }
}

// --- QUẢN LÝ DIALOG VÀ EXTENSION ---

/// Lớp quản lý trạng thái hiển thị của dialog để tránh các lỗi không mong muốn.
/// (Singleton Pattern)
class _LoadingDialogManager {
  _LoadingDialogManager._();
  static final instance = _LoadingDialogManager._();

  bool _isShowing = false;

  void show(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
    LoadingType type = LoadingType.pulse,
  }) {
    if (_isShowing) return; // Không hiển thị nếu đã có dialog

    _isShowing = true;
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) => PopScope(
        canPop: barrierDismissible,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: LoadingWidget.medium(message: message, type: type),
          ),
        ),
      ),
    ).then((_) {
      _isShowing = false; // Đảm bảo cờ được reset khi dialog đóng
    });
  }

  void hide(BuildContext context) {
    if (_isShowing && Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}

/// Extension trên BuildContext để dễ dàng gọi hiển thị/ẩn dialog.
extension LoadingDialogExtension on BuildContext {
  /// Hiển thị loading dialog một cách an toàn.
  void showLoadingDialog({
    String? message,
    bool barrierDismissible = false,
    LoadingType type = LoadingType.pulse,
  }) {
    _LoadingDialogManager.instance.show(
      this,
      message: message,
      barrierDismissible: barrierDismissible,
      type: type,
    );
  }

  /// Ẩn loading dialog một cách an toàn.
  void hideLoadingDialog() {
    _LoadingDialogManager.instance.hide(this);
  }
}

// --- CÁC WIDGET ANIMATION NỘI BỘ (PRIVATE) ---

class _CircularLoader extends StatefulWidget {
  final Color color;
  final double size;
  const _CircularLoader({required this.color, required this.size});
  @override
  State<_CircularLoader> createState() => _CircularLoaderState();
}

class _CircularLoaderState extends State<_CircularLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: CustomPaint(painter: _CircularPainter(color: widget.color)),
          );
        },
      ),
    );
  }
}

class _CircularPainter extends CustomPainter {
  final Color color;
  _CircularPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: size.width / 2);
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [color.withOpacity(0.1), color],
        stops: const [0.0, 0.75],
        transform: const GradientRotation(math.pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 1.5 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DotsLoader extends StatefulWidget {
  final Color color;
  final double size;
  const _DotsLoader({required this.color, required this.size});
  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  final _dotCount = 3;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _dotCount,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    for (int i = 0; i < _dotCount; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = widget.size * 0.2;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_dotCount, (index) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(
                parent: _controllers[index],
                curve: Curves.easeOut,
              ),
            ),
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PulseLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _PulseLoader({required this.color, required this.size});

  @override
  State<_PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<_PulseLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withOpacity(_opacityAnimation.value),
                      width: 2.w,
                    ),
                  ),
                ),
              ),
              Container(
                width: widget.size * 0.3,
                height: widget.size * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SpinnerLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _SpinnerLoader({required this.color, required this.size});

  @override
  State<_SpinnerLoader> createState() => _SpinnerLoaderState();
}

class _SpinnerLoaderState extends State<_SpinnerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _SpinnerPainter(
              color: widget.color,
              progress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final Color color;
  final double progress;

  _SpinnerPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    for (int i = 0; i < 3; i++) {
      final angle = (progress * 2 * math.pi) + (i * 2.0);
      paint.color = color.withOpacity(1.0 - (i * 0.3));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        1.5, // sweep angle
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _WaveLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _WaveLoader({required this.color, required this.size});

  @override
  State<_WaveLoader> createState() => _WaveLoaderState();
}

class _WaveLoaderState extends State<_WaveLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  final int _barCount = 5;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _barCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 400 + (index * 100)),
        vsync: this,
      ),
    );

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barWidth = widget.size * 0.1;
    final maxHeight = widget.size;

    return SizedBox(
      width: widget.size,
      height: maxHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_barCount, (index) {
          return AnimatedBuilder(
            animation: _controllers[index],
            builder: (context, child) {
              return Container(
                width: barWidth,
                height: maxHeight *
                    Tween<double>(begin: 0.2, end: 1.0)
                        .animate(
                          CurvedAnimation(
                            parent: _controllers[index],
                            curve: Curves.easeInOut,
                          ),
                        )
                        .value,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(barWidth),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class _GearLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _GearLoader({required this.color, required this.size});

  @override
  State<_GearLoader> createState() => _GearLoaderState();
}

class _GearLoaderState extends State<_GearLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: CustomPaint(painter: _GearPainter(color: widget.color)),
          );
        },
      ),
    );
  }
}

class _GearPainter extends CustomPainter {
  final Color color;
  _GearPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;
    final path = Path();

    // Draw gear teeth
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      final p1 =
          center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      final p2 = center +
          Offset(
            math.cos(angle) * radius * 1.2,
            math.sin(angle) * radius * 1.2,
          );
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);
    }

    canvas.drawCircle(center, radius, paint);
    canvas.drawPath(path, paint..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
