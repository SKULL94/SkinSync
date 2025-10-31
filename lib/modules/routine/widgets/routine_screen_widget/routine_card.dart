import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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
  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Routine?"),
          content: const Text("Are you sure you want to delete this routine?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false; // default to false if dismissed
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = controller.isDateCompleted(routine);
    final now = DateTime.now();
    final isPastDate = controller.selectedDate.value
        .isBefore(DateTime(now.year, now.month, now.day));
    final cardColor = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).dividerColor;
    final routineCardTheme = Theme.of(context);

    return Obx(() {
      final selectedDate = controller.selectedDate.value;
      return Dismissible(
        key: ValueKey('${routine.id}-${selectedDate.toIso8601String()}'),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child:
              const Icon(Icons.delete_forever, color: Colors.white, size: 30),
        ),
        confirmDismiss: (_) => _confirmDelete(context),
        onDismissed: (_) => controller.deleteRoutine(routine.id),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: routineCardTheme.shadowColor.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        RoutineScreenProgressIndicator(routine: routine),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                routine.name,
                                style: TextStyle(
                                  fontSize: getResponsiveFontSize(context, 16),
                                  fontWeight: FontWeight.w600,
                                  color: routineCardTheme.colorScheme.onSurface,
                                ),
                              ),
                              if (routine.description.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    routine.description,
                                    style: TextStyle(
                                      color: routineCardTheme
                                          .colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                      fontSize:
                                          getResponsiveFontSize(context, 14),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (routine.imagePath?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 12),
                      RoutineScreenRoutineImage(routine: routine),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!isPastDate)
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () =>
                                controller.toggleRoutineCompletion(routine.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : routineCardTheme
                                        .colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isCompleted
                                        ? Icons.check
                                        : Icons.access_time,
                                    size: 18,
                                    color: isCompleted
                                        ? Colors.green
                                        : routineCardTheme
                                            .colorScheme.onSurface,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isCompleted ? "Completed" : "Pending",
                                    style: TextStyle(
                                      color: isCompleted
                                          ? Colors.green
                                          : routineCardTheme
                                              .colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Text(
                          routine.time.format(context),
                          style: TextStyle(
                            fontSize: getResponsiveFontSize(context, 16),
                            fontWeight: FontWeight.w600,
                            color: getTimeColor(
                                context, routine, isCompleted, isPastDate),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: getHeight(context, 8),
                right: getHeight(context, 8),
                child: IconButton(
                  icon: Icon(Icons.close_rounded,
                      size: 20,
                      color: routineCardTheme.colorScheme.onSurface
                          .withValues(alpha: 0.4)),
                  onPressed: () async {
                    final shouldDelete = await _confirmDelete(context);
                    if (shouldDelete) {
                      controller.deleteRoutine(routine.id);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Color getTimeColor(BuildContext context, CustomRoutine routine,
      bool isCompleted, bool isPastDate) {
    if (isCompleted) return Colors.green;
    if (isPastDate) return Colors.grey;

    final now = DateTime.now();
    final routineTime = DateTime(
      now.year,
      now.month,
      now.day,
      routine.time.hour,
      routine.time.minute,
    );

    if (routineTime.isBefore(now)) {
      return Colors.orange;
    }

    return Theme.of(context).colorScheme.primary;
  }
}
