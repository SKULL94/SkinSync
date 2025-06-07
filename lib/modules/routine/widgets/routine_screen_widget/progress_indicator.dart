import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/model/custom_routine.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class RoutineScreenProgressIndicator extends StatelessWidget {
  const RoutineScreenProgressIndicator({super.key, required this.routine});

  final CustomRoutine routine;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: routine.completionProgress,
          strokeWidth: 3,
          color: Theme.of(Get.context!).primaryColor,
          backgroundColor: Colors.grey[200],
        ),
        Icon(
          routine.localIconPath.isEmpty
              ? Icons.self_improvement_rounded
              : Icons.checklist_rounded,
          size: getHeight(context, 22),
          color: Theme.of(Get.context!).primaryColor,
        ),
      ],
    );
  }
}
