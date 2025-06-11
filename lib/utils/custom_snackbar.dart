import 'package:flutter/material.dart';
import 'package:get/get.dart';

SnackbarController showCustomSnackbar(String title, String message,
    {Duration? duration}) {
  final isDarkMode = Get.isDarkMode;

  Icon icon = title.toLowerCase() == 'error'
      ? const Icon(Icons.error, color: Colors.redAccent)
      : const Icon(Icons.check_circle, color: Colors.green);

  return Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.TOP,
    backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
    colorText: isDarkMode ? Colors.white : Colors.black87,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    borderRadius: 12,
    duration: duration ?? Duration(seconds: 2),
    icon: icon,
    shouldIconPulse: false,
    padding: const EdgeInsets.all(16),
    boxShadows: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
