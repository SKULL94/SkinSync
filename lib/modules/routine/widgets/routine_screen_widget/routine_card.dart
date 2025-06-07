import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/model/custom_routine.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/modules/routine/widgets/routine_screen_widget/progress_indicator.dart';
import 'package:skin_sync/modules/routine/widgets/routine_screen_widget/routine_image.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class RoutineScreenRoutineCard extends StatelessWidget {
  const RoutineScreenRoutineCard({
    super.key,
    required this.controller,
    required this.routine,
  });

  final RoutineController controller;
  final CustomRoutine routine;

  @override
  Widget build(BuildContext context) {
    final isCompleted = controller.isDateCompleted(routine);
    final timeColor =
        isCompleted ? Colors.green[700] : Theme.of(context).primaryColor;
    return Obx(() {
      final selectedDate = controller.selectedDate.value;
      return Dismissible(
        key: Key('${routine.id}-${selectedDate.toIso8601String()}'),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: getHeight(context, 20)),
          child:
              const Icon(Icons.delete_forever, color: Colors.white, size: 30),
        ),
        confirmDismiss: (_) async {
          return await Get.dialog(AlertDialog(
            title: const Text("Delete Routine?"),
            content:
                const Text("Are you sure you want to delete this routine?"),
            actions: [
              TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () => Get.back(result: true),
                  child: const Text("Delete",
                      style: TextStyle(color: Colors.red))),
            ],
          ));
        },
        onDismissed: (_) {
          controller.deleteRoutine(routine.id);
        },
        child: InkWell(
          borderRadius: BorderRadius.circular(getWidth(context, 15)),
          onTap: () => controller.toggleRoutineCompletion(routine.id),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(getWidth(context, 15)),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: getHeight(context, 16),
                      horizontal: getWidth(context, 16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          RoutineScreenProgressIndicator(routine: routine),
                          SizedBox(width: getWidth(context, 16)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(routine.name,
                                    style: TextStyle(
                                        fontSize:
                                            getResponsiveFontSize(context, 14),
                                        fontWeight: FontWeight.w600)),
                                if (routine.description.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: getHeight(context, 4)),
                                    child: Text(routine.description,
                                        style: TextStyle(
                                            // color: Colors.grey[600],
                                            fontSize: getResponsiveFontSize(
                                                context, 14))),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: getHeight(context, 12)),
                      if (routine.imagePath.isNotEmpty)
                        RoutineScreenRoutineImage(routine: routine),
                      SizedBox(height: getHeight(context, 12)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(
                              isCompleted ? "Completed" : "Pending",
                            ),
                            avatar: Icon(
                                isCompleted ? Icons.check : Icons.access_time,
                                size: getHeight(context, 18),
                                color: isCompleted
                                    ? Colors.green[800]
                                    : Colors.grey[600]),
                          ),
                          Text(routine.time.format(Get.context!),
                              style: TextStyle(
                                  fontSize: getResponsiveFontSize(context, 16),
                                  fontWeight: FontWeight.w600,
                                  color: timeColor)),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: getHeight(context, 16),
                  right: getHeight(context, 16),
                  child: IconButton(
                    icon: Icon(Icons.close_rounded,
                        size: getHeight(context, 20), color: Colors.grey[500]),
                    onPressed: () => controller.deleteRoutine(routine.id),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
