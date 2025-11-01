import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../components/verity_2fa_login_dialog.dart';

@RoutePage()
class Verify2FALoginPage extends StatelessWidget {
  const Verify2FALoginPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Verify2FALoginDialog()),
    );
  }
}
