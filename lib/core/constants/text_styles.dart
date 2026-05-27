import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';

/// App Text Styles - AURA Design System
class AppTextStyles {
  AppTextStyles._();

  // Fallback font families for offline mode
  static const List<String> _serifFallback = ['Georgia', 'Times New Roman', 'serif'];
  static const List<String> _sansFallback = ['Helvetica Neue', 'Helvetica', 'Arial', 'sans-serif'];

  // Headings - Playfair Display with fallback
  static TextStyle get heading1 => GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.2,
      ).copyWith(fontFamilyFallback: _serifFallback);

  static TextStyle get heading2 => GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.2,
      ).copyWith(fontFamilyFallback: _serifFallback);

  static TextStyle get heading3 => GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.2,
      ).copyWith(fontFamilyFallback: _serifFallback);

  static TextStyle get heading4 => GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.2,
      ).copyWith(fontFamilyFallback: _serifFallback);

  static TextStyle get headingItalic => GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        color: AppColors.textPrimary,
        height: 1.2,
      ).copyWith(fontFamilyFallback: _serifFallback);

  // Body Text - DM Sans with fallback
  static TextStyle get bodyLarge => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      ).copyWith(fontFamilyFallback: _sansFallback);

  static TextStyle get bodyMedium => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      ).copyWith(fontFamilyFallback: _sansFallback);

  static TextStyle get bodySmall => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w300,
        color: AppColors.textTertiary,
        height: 1.7,
      ).copyWith(fontFamilyFallback: _sansFallback);

  // Labels
  static TextStyle get labelLarge => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ).copyWith(fontFamilyFallback: _sansFallback);

  static TextStyle get labelMedium => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ).copyWith(fontFamilyFallback: _sansFallback);

  static TextStyle get labelSmall => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
        color: AppColors.textTertiary,
      ).copyWith(fontFamilyFallback: _sansFallback);

  // Button Text
  static TextStyle get buttonPrimary => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        letterSpacing: 0.5,
      ).copyWith(fontFamilyFallback: _sansFallback);

  static TextStyle get buttonSecondary => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
        letterSpacing: 0.5,
      ).copyWith(fontFamilyFallback: _sansFallback);

  // Input Text
  static TextStyle get inputText => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ).copyWith(fontFamilyFallback: _sansFallback);

  static TextStyle get inputHint => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
      ).copyWith(fontFamilyFallback: _sansFallback);

  // Caption
  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
      ).copyWith(fontFamilyFallback: _sansFallback);

  // Overline
  static TextStyle get overline => GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
        color: AppColors.textTertiary,
      ).copyWith(fontFamilyFallback: _sansFallback);
}
