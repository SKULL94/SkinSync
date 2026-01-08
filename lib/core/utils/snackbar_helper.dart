import 'package:flutter/material.dart';

class SnackbarHelper {
  SnackbarHelper._();

  static void showError(BuildContext context, String message) {
    _showSnackbar(
      context,
      message: message,
      icon: const Icon(Icons.error, color: Colors.white),
      backgroundColor: Colors.redAccent,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(
      context,
      message: message,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      backgroundColor: Colors.green,
    );
  }

  static void showInfo(BuildContext context, String message) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    _showSnackbar(
      context,
      message: message,
      icon: Icon(
        Icons.info,
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
      backgroundColor: isDarkMode ? Colors.grey[800]! : Colors.white,
      textColor: isDarkMode ? Colors.white : Colors.black87,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackbar(
      context,
      message: message,
      icon: const Icon(Icons.warning, color: Colors.white),
      backgroundColor: Colors.orange,
    );
  }

  static void _showSnackbar(
    BuildContext context, {
    required String message,
    required Icon icon,
    required Color backgroundColor,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: duration,
      ),
    );
  }

  static void showPersistentError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(days: 1),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
