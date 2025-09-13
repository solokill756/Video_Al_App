import 'dart:io';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:rate_my_app/rate_my_app.dart';

import '../../core/data/local/storage.dart';
import 'app_environment.dart';

abstract class RatingService {
  Future<void> rateApp(BuildContext context);
}

@LazySingleton(as: RatingService)
class RatingServiceImpl extends RatingService {
  @override
  Future<void> rateApp(BuildContext context) async {
    final bool contextIsValid = context.mounted;
    if (!contextIsValid) return;

    RateMyApp rateMyApp = RateMyApp(
      minDays: 0,
      minLaunches: 0,
      remindDays: 0,
      remindLaunches: 0,
      preferencesPrefix: "rateMyApp_",
      googlePlayIdentifier: AppEnvironment.googlePlayId,
      appStoreIdentifier: AppEnvironment.appStoreId,
    );

    await rateMyApp.init();

    if (!contextIsValid) return;

    final bool? userRated = Storage.ratingShown;
    if ((userRated == null || !userRated) && contextIsValid) {
      await rateMyApp.showStarRateDialog(
        // ignore: use_build_context_synchronously
        context,
        title: "Love Our App? Rate Us!",
        message:
            "Your feedback helps us grow. Please take a moment to rate us on the ${Platform.isAndroid ? 'Google Play Store' : 'App Store'}. Thank you for your support!",
        actionsBuilder: (context, stars) {
          return [
            TextButton(
              onPressed: () async {
                stars = stars ?? 0;

                if (stars! < 4) {
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context, RateMyAppDialogButton.rate);
                  await rateMyApp
                      .callEvent(RateMyAppEventType.rateButtonPressed);
                  if ((await rateMyApp.isNativeReviewDialogSupported) ??
                      false) {
                    await rateMyApp.launchNativeReviewDialog();
                  } else {
                    rateMyApp.launchStore();
                  }
                  await Storage.setRatingShown(true);
                }
              },
              child: const Text('OK'),
            )
          ];
        },
        ignoreNativeDialog: Platform.isAndroid,
        dialogStyle: const DialogStyle(
          titleAlign: TextAlign.center,
          messageAlign: TextAlign.center,
          messagePadding: EdgeInsets.only(bottom: 20),
        ),
        starRatingOptions: const StarRatingOptions(),
        onDismissed: () {
          rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
        },
      );
    }
  }
}
