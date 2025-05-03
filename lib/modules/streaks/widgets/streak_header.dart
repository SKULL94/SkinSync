import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/streaks/streaks_controller.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class StreakHeader extends StatelessWidget {
  final StreaksController controller;

  const StreakHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Streak',
          style: TextStyle(
            fontSize: getResponsiveFontSize(context, 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: getHeight(context, 8)),
        Obx(() => Text(
              '${controller.streaks} day${controller.streaks == 1 ? '' : 's'}',
              style: TextStyle(
                fontSize: getResponsiveFontSize(context, 36),
                fontWeight: FontWeight.w900,
                color: Theme.of(context).primaryColor,
              ),
            )),
      ],
    );
  }
}
