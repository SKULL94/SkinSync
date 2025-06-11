import 'package:flutter/material.dart';
import 'package:skin_sync/app.dart';
import 'package:skin_sync/services/service_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceBinding.init();
  runApp(const MyApp());
}
