import 'package:flutter/material.dart';
import 'package:skin_sync/core/constants/color_const.dart';

class AuthProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const AuthProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isDone = index < currentStep;
        final isCurrent = index == currentStep;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: (isDone || isCurrent) ? 32 : 24,
          height: 3,
          margin: EdgeInsets.only(left: index == 0 ? 0 : 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: isDone || isCurrent
                ? AppColors.primary
                : AppColors.cardBorder,
          ),
        );
      }),
    );
  }
}
