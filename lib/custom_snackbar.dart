import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showErrorSnackbar(String title, String message) {
  final isDarkMode = Get.isDarkMode;

  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.TOP,
    backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
    colorText: isDarkMode ? Colors.white : Colors.black87,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    borderRadius: 12,
    duration: const Duration(seconds: 4),
    icon: const Icon(Icons.error, color: Colors.redAccent),
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
