import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';

class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.hankenGrotesk(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.8,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
