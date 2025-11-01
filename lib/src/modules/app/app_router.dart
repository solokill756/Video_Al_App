import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../../common/guards/auth_guard.dart';
import '../Settings/presentation/pages/profile_page.dart';
import '../Settings/presentation/pages/settings_page.dart';
import '../auth/presentation/pages/forgot_password_detail_page.dart';
import '../auth/presentation/pages/forgot_password_page.dart';
import '../auth/presentation/pages/login_page.dart';
import '../auth/presentation/pages/register_page.dart';
import '../auth/presentation/pages/register_detail_page.dart';
import '../home/presentation/pages/home_page.dart';
import '../upload/presentation/pages/upload_video_page.dart';
import '../auth/presentation/pages/verify_2fa_login_page.dart';
import 'pages/app_shell_page.dart';
import 'splash_page.dart';

part 'app_router.gr.dart';

@singleton
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends _$AppRouter {
  final _authGuard = AuthGuard();
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, path: '/splash'),
        AutoRoute(page: LoginRoute.page, path: '/login'),
        AutoRoute(page: RegisterRoute.page, path: '/register'),
        AutoRoute(page: RegisterDetailRoute.page, path: '/register-detail'),
        AutoRoute(
          page: ForgotPasswordRoute.page,
          path: '/forgot-password',
        ),
        AutoRoute(
            page: ForgotPasswordDetailRoute.page,
            path: '/forgot-password-detail'),
        AutoRoute(
          page: Verify2FALoginRoute.page,
          path: '/two-factor-auth',
        ),
        // Shell route wrapping home, profile, and upload pages
        AutoRoute(
          page: AppShellRoute.page,
          path: '/',
          guards: [_authGuard],
          children: [
            AutoRoute(
              page: VideoSearchHomeRoute.page,
              path: '',
            ),
            AutoRoute(
              page: ProfileRoute.page,
              path: 'profile',
            ),
            AutoRoute(
              page: UploadVideoRoute.page,
              path: 'upload',
            ),
          ],
        ),
        AutoRoute(
            page: SettingsRoute.page, path: '/settings', guards: [_authGuard]),
      ];
}
