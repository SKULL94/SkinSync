import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/services/storage.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
        color: Theme.of(context).iconTheme.color,
      ),
      onPressed: () {
        final newTheme = Get.isDarkMode ? 'light' : 'dark';
        Get.changeThemeMode(
            newTheme == 'dark' ? ThemeMode.dark : ThemeMode.light);
        StorageService.instance.save('theme', newTheme);
      },
      splashRadius: 24,
    );
  }
}
