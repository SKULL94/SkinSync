import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';

/// Skinsight Type Scale
/// Numbers/scores/titles → Space Grotesk
/// UI/body/buttons/labels → Hanken Grotesk
class AppTextStyles {
  AppTextStyles._();

  // ── Display / score (Space Grotesk) ────────────────────────────────────
  static TextStyle get scoreHero => GoogleFonts.spaceGrotesk(
        fontSize: 58,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.58,
      );

  static TextStyle get heading1 => GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.24,
        height: 1.2,
      );

  static TextStyle get heading2 => GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.20,
        height: 1.25,
      );

  static TextStyle get heading3 => GoogleFonts.spaceGrotesk(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get heading4 => GoogleFonts.spaceGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  static TextStyle get headingItalic => GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.20,
        height: 1.25,
      );

  // ── Body (Hanken Grotesk) ───────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.hankenGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.55,
      );

  static TextStyle get bodyMedium => GoogleFonts.hankenGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
        height: 1.55,
      );

  static TextStyle get bodySmall => GoogleFonts.hankenGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
        height: 1.55,
      );

  // ── Labels (Hanken Grotesk) ────────────────────────────────────────────
  static TextStyle get labelLarge => GoogleFonts.hankenGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMedium => GoogleFonts.hankenGrotesk(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelSmall => GoogleFonts.hankenGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.muted,
      );

  // ── Overline (Hanken Grotesk uppercase) ────────────────────────────────
  static TextStyle get overline => GoogleFonts.hankenGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
        letterSpacing: 0.12 * 11,
      );

  // ── Button (Hanken Grotesk) ────────────────────────────────────────────
  static TextStyle get buttonPrimary => GoogleFonts.hankenGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get buttonSecondary => GoogleFonts.hankenGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      );

  // ── Input (Hanken Grotesk) ────────────────────────────────────────────
  static TextStyle get inputText => GoogleFonts.hankenGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get inputHint => GoogleFonts.hankenGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.muted2,
      );

  // ── Caption / legal ───────────────────────────────────────────────────
  static TextStyle get caption => GoogleFonts.hankenGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.muted,
        height: 1.5,
      );

  static TextStyle get legal => GoogleFonts.hankenGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.muted2,
        height: 1.6,
      );
}
