import 'package:flutter/material.dart';

/// Widget loading dùng chung cho toàn bộ app
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;
  final bool showBackground;
  final Color? backgroundColor;

  const LoadingWidget({
    super.key,
    this.message,
    this.size,
    this.color,
    this.showBackground = true,
    this.backgroundColor,
  });

  /// Loading indicator nhỏ cho button
  const LoadingWidget.small({
    super.key,
    this.message,
    this.color,
    this.showBackground = false,
    this.backgroundColor,
  }) : size = 20;

  /// Loading indicator trung bình
  const LoadingWidget.medium({
    super.key,
    this.message,
    this.color,
    this.showBackground = true,
    this.backgroundColor,
  }) : size = 32;

  /// Loading indicator lớn cho toàn màn hình
  const LoadingWidget.large({
    super.key,
    this.message,
    this.color,
    this.showBackground = true,
    this.backgroundColor,
  }) : size = 48;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.primaryColor;
    final effectiveSize = size ?? 32.0;

    Widget loadingIndicator = SizedBox(
      width: effectiveSize,
      height: effectiveSize,
      child: CircularProgressIndicator(
        strokeWidth: effectiveSize * 0.08,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
      ),
    );

    if (message != null) {
      loadingIndicator = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingIndicator,
          SizedBox(height: effectiveSize * 0.5),
          Text(
            message!,
            style: TextStyle(
              fontSize: effectiveSize * 0.35,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (!showBackground) {
      return loadingIndicator;
    }

    return Container(
      color: backgroundColor ?? Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(effectiveSize * 0.75),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: loadingIndicator,
        ),
      ),
    );
  }
}

/// Extension để hiển thị loading dialog
extension LoadingDialog on BuildContext {
  /// Hiển thị loading dialog
  void showLoadingDialog({
    String? message,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) => WillPopScope(
        onWillPop: () async => barrierDismissible,
        child: LoadingWidget.medium(
          message: message,
          showBackground: false,
        ),
      ),
    );
  }

  /// Ẩn loading dialog
  void hideLoadingDialog() {
    if (Navigator.canPop(this)) {
      Navigator.pop(this);
    }
  }
}

/// Widget overlay loading cho toàn màn hình
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          LoadingWidget.large(
            message: message,
            backgroundColor: backgroundColor,
          ),
      ],
    );
  }
}

/// Loading widget cho button với custom design
class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String text;
  final String? loadingText;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
    this.loadingText,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 52,
    this.borderRadius = 12,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFF0D9488),
          foregroundColor: foregroundColor ?? Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          disabledBackgroundColor:
              (backgroundColor ?? const Color(0xFF0D9488)).withOpacity(0.6),
          padding: padding,
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LoadingWidget.small(
                    color: Colors.white,
                    showBackground: false,
                  ),
                  if (loadingText != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      loadingText!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Loading widget với animation xoay custom
class CustomLoadingWidget extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const CustomLoadingWidget({
    super.key,
    this.size = 32,
    this.color = const Color(0xFF0D9488),
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<CustomLoadingWidget> createState() => _CustomLoadingWidgetState();
}

class _CustomLoadingWidgetState extends State<CustomLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animationController.value * 2 * 3.14159,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color.withOpacity(0.3),
                  width: widget.size * 0.08,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: widget.size * 0.4,
                    child: Container(
                      width: widget.size * 0.08,
                      height: widget.size * 0.3,
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(widget.size * 0.04),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
