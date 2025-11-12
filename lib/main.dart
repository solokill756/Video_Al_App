import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_it/get_it.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:talker_bloc_logger/talker_bloc_logger_observer.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'src/common/utils/app_environment.dart';
import 'src/common/utils/getit_utils.dart';
import 'src/common/widgets/only_one_point_widget.dart';
import 'src/core/data/local/storage.dart';
import 'src/modules/Settings/presentation/application/cubit/settings_cubit.dart';
import 'src/modules/app/app_router.dart';
import 'src/modules/app/app_widget.dart';
import 'src/modules/auth/presentation/application/cubit/auth_cubit.dart';
import 'src/modules/upload/domain/repository/upload_repository.dart';
import 'src/modules/upload/presentation/application/cubit/upload_cubit.dart';
import 'src/modules/plan/presentation/application/cubit/plan_cubit.dart'
    as plan_cubit;
import 'src/modules/video_list/presentation/application/cubit/video_cubit.dart'
    as video_list_cubit;
import 'src/modules/video_detail/presentation/application/cubit/video_detail_cubit.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    // await HiveBoxes.init();
    await AppEnvironment.setup();
    await Storage.setup();
    await GetItUtils.setup();

    final talker = getIt<Talker>();
    _setupErrorHooks(talker);

    Bloc.observer = TalkerBlocObserver(talker: talker);

    runApp(
      OnlyOnePointerRecognizerWidget(
        child: MultiProvider(
          providers: [
            BlocProvider(
              create: (context) => GetIt.instance<AuthCubit>(),
            ),
            BlocProvider(
              create: (context) => GetIt.instance<SettingsCubit>(),
            ),
            BlocProvider(
              create: (context) => UploadCubit(
                uploadRepository: getIt<UploadRepository>(),
              ),
            ),
            BlocProvider(
              create: (context) => getIt<plan_cubit.PlanCubit>(),
            ),
            BlocProvider(
              create: (context) => getIt<video_list_cubit.VideoCubit>(),
            ),
            BlocProvider(
              create: (context) => getIt<VideoDetailCubit>(),
            ),
          ],
          child: const AppWidget(),
        ),
      ),
    );
    configLoading();
  }, (error, stack) {
    getIt<Talker>().handle(error, stack);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: Sizer(builder: (context, orientation, deviceType) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          builder: EasyLoading.init(),
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          title: 'VideoAI',
          routerConfig: getIt<AppRouter>().config(),
        );
      }),
    );
  }
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2500)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.white
    ..backgroundColor = Colors.black
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..userInteractions = false
    ..maskType = EasyLoadingMaskType.black
    ..dismissOnTap = true;
}

Future _setupErrorHooks(Talker talker, {bool catchFlutterErrors = true}) async {
  if (catchFlutterErrors) {
    FlutterError.onError = (FlutterErrorDetails details) async {
      _reportError(details.exception, details.stack, talker);
    };
  }
  PlatformDispatcher.instance.onError = (error, stack) {
    _reportError(error, stack, talker);
    return true;
  };

  /// Web doesn't have Isolate error listener support
  if (!kIsWeb) {
    Isolate.current.addErrorListener(RawReceivePort((dynamic pair) async {
      final isolateError = pair as List<dynamic>;
      _reportError(
        isolateError.first.toString(),
        isolateError.last.toString(),
        talker,
      );
    }).sendPort);
  }
}

void _reportError(dynamic error, dynamic stackTrace, Talker talker) async {
  talker.error('Unhandled Exception', error, stackTrace);
}
