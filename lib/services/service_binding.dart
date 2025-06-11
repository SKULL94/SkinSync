import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:skin_sync/services/firebase_options.dart';
import 'package:skin_sync/services/firestore_queue.dart';
import 'package:skin_sync/services/internet_service.dart';
import 'package:skin_sync/services/notification_service.dart';
import 'package:skin_sync/services/sqflite_database.dart';
import 'package:skin_sync/services/supabase_services.dart';
import 'package:workmanager/workmanager.dart';

class ServiceBinding {
  static Future<void> init() async {
    await GetStorage.init();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await Workmanager().initialize(
      FirestoreQueueService.callbackDispatcher,
      isInDebugMode: false,
    );
    await SupabaseService.init();
    await DatabaseHelper.instance.database;

    Get.put(ConnectivityService());
    final notificationService = NotificationService();
    await notificationService.init();
    Get.put(notificationService);
  }
}
