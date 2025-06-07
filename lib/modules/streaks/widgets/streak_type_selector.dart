import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/streaks/streaks_controller.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class StreakTypeSelector extends StatelessWidget {
  final StreaksController controller;

  const StreakTypeSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: getHeight(context, 16),
        horizontal: getWidth(context, 16),
      ),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTypeButton('Daily', StreakType.daily, context),
              _buildTypeButton('Weekly', StreakType.weekly, context),
              _buildTypeButton('Perfect', StreakType.monthly, context),
            ],
          )),
    );
  }

  Widget _buildTypeButton(String label, StreakType type, BuildContext context) {
    final isActive = controller.currentStreakType.value == type;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => controller.changeStreakType(type),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: getHeight(context, 16),
          horizontal: getWidth(context, 16),
        ),
        decoration: BoxDecoration(
          color: isActive ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(getWidth(context, 20)),
          border: Border.all(color: theme.primaryColor, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: getResponsiveFontSize(context, 14)),
        ),
      ),
    );
  }
}
