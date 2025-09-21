import 'package:auto_route/auto_route.dart';

import '../../core/data/local/storage.dart';
import '../../modules/app/app_router.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final isLoggedIn = await Storage.accessToken;
    if (isLoggedIn != null) {
      resolver.next(true);
    } else {
      router.pushAndPopUntil(
        const LoginRoute(),
        predicate: (route) => false,
      );
    }
  }
}
