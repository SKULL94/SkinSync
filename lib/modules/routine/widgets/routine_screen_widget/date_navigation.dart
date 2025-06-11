import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class RoutineScreenDateNavigation extends StatelessWidget {
  final RoutineController controller;
  final DateFormat dateFormat;
  const RoutineScreenDateNavigation(
      {super.key, required this.controller, required this.dateFormat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Obx(() => Container(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left_rounded,
                      color: Theme.of(context).colorScheme.primary),
                  onPressed: () => controller.selectedDate.value = controller
                      .selectedDate.value
                      .subtract(const Duration(days: 1)),
                ),
                Column(
                  children: [
                    Text(
                      dateFormat.format(controller.selectedDate.value),
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Completed: ${controller.completedCount}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                        fontSize: getResponsiveFontSize(context, 14),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right_rounded,
                      color: Theme.of(context).colorScheme.primary),
                  onPressed: () => controller.selectedDate.value = controller
                      .selectedDate.value
                      .add(const Duration(days: 1)),
                ),
              ],
            ),
          )),
    );
  }
}
