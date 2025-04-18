import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:skin_sync/app.dart';
import 'package:skin_sync/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://rpzttytepebvihryrjqx.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJwenR0eXRlcGVidmlocnlyanF4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ5Nzc4OTcsImV4cCI6MjA2MDU1Mzg5N30.SyGcEyunS-PkbsBWy2KUyeKjbOBJPAAr9KB-i4h7D88');
  await GetStorage.init();
  await Firebase.initializeApp();

  // Initialize notifications
  await NotificationService().initialize();
  await NotificationService().scheduleDailyRoutineReminders();

  runApp(const MyApp());
}
