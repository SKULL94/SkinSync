import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/splash/app_splash_screen.dart';
import 'package:skin_sync/utils/app_constants.dart';
import 'package:skin_sync/services/storage.dart';
import 'routes/app_pages.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  ThemeMode get themeMode {
    final themeString = StorageService.instance.fetch(AppConstants.theme) ??
        AppConstants.systemTheme;
    return themeString == AppConstants.darkTheme
        ? ThemeMode.dark
        : themeString == AppConstants.lightTheme
            ? ThemeMode.light
            : ThemeMode.system;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: FlexThemeData.light(
          scheme: FlexScheme.bahamaBlue, useMaterial3: true),
      darkTheme:
          FlexThemeData.dark(scheme: FlexScheme.damask, useMaterial3: true),
      themeMode: themeMode,
      // navigatorKey: Get.key,
      debugShowCheckedModeBanner: false,
      title: 'Daily Skin Care Routine App',
      routerConfig: appRouter,
      // getPages: AppPages.pages,
      // home: AppSplashScreen(),
    );
  }
}
