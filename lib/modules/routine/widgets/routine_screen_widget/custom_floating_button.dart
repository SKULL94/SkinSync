import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/routine/custom_routine_screen.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final RoutineController controller;

  const CustomFloatingActionButton({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    return Obx(() {
      final selectedDate = controller.selectedDate.value;
      final isPastDate = selectedDate.isBefore(normalizedToday);

      return FloatingActionButton.extended(
        icon: const Icon(Icons.add_task_rounded),
        label: const Text("New Routine"),
        onPressed:
            isPastDate ? null : () => Get.to(() => CreateRoutineScreen()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
    });
  }
}
