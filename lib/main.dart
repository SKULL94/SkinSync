import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:skin_sync/app.dart';
import 'package:skin_sync/services/firebase_options.dart';
import 'package:skin_sync/services/firestore_queue.dart';
import 'package:skin_sync/services/internet_service.dart';
import 'package:skin_sync/services/notification_service.dart';
import 'package:skin_sync/services/sqflite_database.dart';
import 'package:skin_sync/services/supabase_services.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();
  await Workmanager().initialize(
    FirestoreQueueService.callbackDispatcher,
    isInDebugMode: false,
  );

  await SupabaseService.init();
  await DatabaseHelper.instance.database;
  Get.put(ConnectivityService());

  runApp(const MyApp());
}
