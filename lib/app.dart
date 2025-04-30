import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/utils/app_utils.dart';
import 'package:skin_sync/utils/storage.dart';
import 'routes/app_pages.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;
    // Get stored theme or default to system
    final themeString = storage.fetch('theme') ?? 'system';
    final ThemeMode themeMode = themeString == 'dark'
        ? ThemeMode.dark
        : themeString == 'light'
            ? ThemeMode.light
            : ThemeMode.system;
    return GetMaterialApp(
      theme: FlexThemeData.light(
          scheme: FlexScheme.bahamaBlue, useMaterial3: true),
      darkTheme:
          FlexThemeData.dark(scheme: FlexScheme.damask, useMaterial3: true),
      themeMode: themeMode,
      navigatorKey: Get.key,
      debugShowCheckedModeBanner: false,
      title: 'Daily Routine App',
      initialRoute: AppUtils.checkUser(),
      getPages: AppPages.pages,
    );
  }
}
