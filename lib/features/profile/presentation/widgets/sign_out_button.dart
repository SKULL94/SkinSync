import 'package:flutter/material.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/constants/text_styles.dart';

class SignOutButton extends StatelessWidget {
  final VoidCallback onTap;

  const SignOutButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.rose.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            StringConst.kSignOut,
            style: AppTextStyles.buttonPrimary.copyWith(
              color: AppColors.rose,
            ),
          ),
        ),
      ),
    );
  }
}
