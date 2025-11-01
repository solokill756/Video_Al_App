import 'package:auto_route/auto_route.dart';

import '../../core/data/local/storage.dart';
import '../../modules/app/app_router.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final isLoggedIn = await Storage.accessToken;
    final isEnable2FA = Storage.isEnable2FA;
    if (isLoggedIn != null && (isEnable2FA == null || isEnable2FA == false)) {
      resolver.next(true);
    } else if (isLoggedIn != null && isEnable2FA == true) {
      router.push(
        Verify2FALoginRoute(),
      );
    } else {
      router.pushAndPopUntil(
        const LoginRoute(),
        predicate: (route) => false,
      );
    }
  }
}
