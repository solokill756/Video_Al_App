import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../../common/guards/auth_guard.dart';
import '../Settings/presentation/pages/settings_page.dart';
import '../auth/presentation/pages/login_page.dart';
import '../home/presentation/pages/home_page.dart';
import 'splash_page.dart';

part 'app_router.gr.dart';

@singleton
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends _$AppRouter {
  final _authGuard = AuthGuard();
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
            page: VideoSearchHomeRoute.page, path: '/', guards: [_authGuard]),
        AutoRoute(page: SplashRoute.page, path: '/slash'),
        AutoRoute(page: LoginRoute.page, path: '/login'),
        AutoRoute(
            page: SettingsRoute.page, path: '/settings', guards: [_authGuard]),
      ];
}
