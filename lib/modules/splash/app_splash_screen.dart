import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/model/tflite/tflite_repository.dart';
import 'package:skin_sync/routes/app_pages.dart';
import 'package:skin_sync/utils/app_utils.dart';

class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({super.key});

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await TFLiteRepository().initialize();
    debugPrint("TFLite initialized");

    final nextRoute = AppUtils.checkUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      appRouter.go(nextRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
