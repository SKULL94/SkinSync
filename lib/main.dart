import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:skin_sync/app.dart';
import 'package:skin_sync/core/di/injection_container.dart' as di;
import 'package:skin_sync/core/services/firebase_options.dart';
import 'package:skin_sync/core/services/notification_service.dart';
import 'package:skin_sync/core/services/sqflite_database.dart';
import 'package:skin_sync/core/services/supabase_services.dart';
import 'package:workmanager/workmanager.dart';
import 'package:skin_sync/core/services/firestore_queue.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await Workmanager().initialize(
        FirestoreQueueService.callbackDispatcher,
        isInDebugMode: false,
      );

      await SupabaseService.init();
      await DatabaseHelper.instance.database;

      await di.init();

      final notificationService = di.sl<NotificationService>();
      await notificationService.init();

      runApp(const MyApp());
    },
    (final error, final stack) {
      /// MARK:- To trace crash if happen
      debugPrint(error.toString());
    },
  );
}
