import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:skin_sync/app.dart';
import 'package:skin_sync/firebase_options.dart';
import 'package:skin_sync/utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  await NotificationService().initialize();
  await NotificationService().scheduleCustomRoutines();

  runApp(const MyApp());
}
