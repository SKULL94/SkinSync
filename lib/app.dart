import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/utils/app_utils.dart';
import 'routes/app_pages.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: Get.key,
      debugShowCheckedModeBanner: false,
      title: 'Daily Routine App',
      initialRoute: AppUtils.checkUser(),
      getPages: AppPages.pages,
    );
  }
}
