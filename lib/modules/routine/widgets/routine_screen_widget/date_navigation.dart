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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
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
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Completed: ${controller.completedCount}',
                    style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                        fontSize: getResponsiveFontSize(context, 14)),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => controller.selectedDate.value =
                    controller.selectedDate.value.add(const Duration(days: 1)),
              ),
            ],
          )),
    );
  }
}
