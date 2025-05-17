import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/modules/streaks/streaks_controller.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class StreakProgressCard extends StatelessWidget {
  final StreaksController controller;
  final RoutineController routineController;

  const StreakProgressCard({
    super.key,
    required this.controller,
    required this.routineController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      padding: EdgeInsets.symmetric(
        vertical: getHeight(context, 20),
        horizontal: getWidth(context, 20),
      ),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(getWidth(context, 16)),
      ),
      child: Column(
        children: [
          Text(
            '🔥 Active Streak',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: theme.secondaryHeaderColor,
            ),
          ),
          SizedBox(height: getHeight(context, 12)),
          Obx(() => Text(
                '${routineController.completedCount}',
                style: TextStyle(
                  fontSize: getResponsiveFontSize(context, 32),
                  fontWeight: FontWeight.bold,
                  color: theme.secondaryHeaderColor,
                ),
              )),
          SizedBox(height: getHeight(context, 8)),
          LinearProgressIndicator(
            value: controller.streaks / 30,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation(Color(0xff964F66)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(getWidth(context, 4)),
          ),
        ],
      ),
    );
  }
}
