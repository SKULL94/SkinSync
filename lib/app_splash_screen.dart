import 'package:flutter/material.dart';
import 'package:skin_sync/model/tflite/tflite_repository.dart';
import 'package:skin_sync/services/notification_service.dart';
import 'package:skin_sync/services/sqflite_database.dart';
import 'package:skin_sync/services/supabase_services.dart';

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
    await Future.wait([
      SupabaseService.init(),
      NotificationService().initialize(),
      DatabaseHelper.instance.database,
    ]);
    TFLiteRepository().initialize().then((_) {
      debugPrint("TFLite initialized");
    });

    // Get.put(ConnectivityService());
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
