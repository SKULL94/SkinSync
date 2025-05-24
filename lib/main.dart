import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:skin_sync/app.dart';
import 'package:skin_sync/firebase_options.dart';
import 'package:skin_sync/utils/notification_service.dart';
import 'package:skin_sync/utils/sqflite_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.database;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  await NotificationService().initialize();

  runApp(const MyApp());
}
