import 'package:flutter/material.dart';

class HideKeyboardOnTap extends StatelessWidget {
  final Widget child;
  const HideKeyboardOnTap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
