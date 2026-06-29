import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';

class SignOutButton extends StatelessWidget {
  final VoidCallback onTap;

  const SignOutButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.alertTint,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.alert.withValues(alpha: 0.30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              size: 17,
              color: AppColors.alertTintInk,
            ),
            const SizedBox(width: 8),
            Text(
              StringConst.kSignOut,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.alertTintInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
