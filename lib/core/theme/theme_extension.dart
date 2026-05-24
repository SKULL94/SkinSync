import 'package:flutter/material.dart';
import 'package:skin_sync/core/constants/color_const.dart';

/// Theme-aware color palette extension
/// Usage: context.colors.background, context.colors.cardBackground, etc.
class AppColorsTheme {
  final bool isDark;

  const AppColorsTheme({required this.isDark});

  // Background colors
  Color get background => isDark ? AppColors.darkBackground : AppColors.background;
  Color get backgroundLight => isDark ? AppColors.darkSurface : AppColors.backgroundLight;

  // Card colors
  Color get cardBackground => isDark ? AppColors.darkSurface : Colors.white;
  Color get cardBorder => isDark ? AppColors.darkCardBorder : AppColors.cardBorder;

  // Text colors
  Color get textPrimary => isDark ? AppColors.textOnDark : AppColors.textPrimary;
  Color get textSecondary => isDark ? const Color(0xFFA89880) : AppColors.textSecondary;
  Color get textTertiary => isDark ? const Color(0xFF7A6A5A) : AppColors.textTertiary;

  // Primary colors (same in both themes for brand consistency)
  Color get primary => AppColors.primary;
  Color get primaryLight => AppColors.primaryLight;
  Color get primaryDark => AppColors.primaryDark;

  // Secondary colors
  Color get sage => AppColors.sage;
  Color get sageLight => AppColors.sageLight;

  // Accent colors
  Color get rose => AppColors.rose;
  Color get amber => AppColors.amber;

  // Dividers and borders
  Color get divider => isDark ? AppColors.darkCardBorder : AppColors.divider;

  // Navigation bar colors
  Color get navBackground => isDark
      ? const Color(0xFF1A1410).withValues(alpha: 0.97)
      : const Color(0xFFF2EDE6).withValues(alpha: 0.97);
  Color get navBorder => isDark
      ? const Color(0xFF3D2E22)
      : const Color(0xFFE0D8CC);
  Color get navInactive => isDark
      ? const Color(0xFF7A6A5A)
      : const Color(0xFFA89880);

  // Status colors
  Color get success => AppColors.success;
  Color get warning => AppColors.warning;
  Color get error => AppColors.error;
  Color get info => AppColors.info;

  // Metric colors
  Color get metricGood => AppColors.metricGood;
  Color get metricMedium => AppColors.metricMedium;
  Color get metricLow => AppColors.metricLow;

  // Shadow and overlay
  Color get shadow => isDark
      ? Colors.black.withValues(alpha: 0.3)
      : AppColors.shadow;
  Color get overlay => isDark
      ? Colors.black.withValues(alpha: 0.5)
      : AppColors.overlay;

  // Glassmorphism
  Color get glassBackground => isDark
      ? const Color(0xFF2A2118).withValues(alpha: 0.9)
      : AppColors.glassBackground;
  Color get glassBorder => isDark
      ? Colors.white.withValues(alpha: 0.1)
      : AppColors.glassBorder;

  // Chip background
  Color get chipBackground => isDark
      ? const Color(0xFF3D2E22)
      : AppColors.chipBackground;

  // Icon colors
  Color get iconPrimary => isDark ? AppColors.textOnDark : AppColors.textPrimary;
  Color get iconSecondary => isDark ? const Color(0xFF7A6A5A) : AppColors.textTertiary;
}

/// Extension to easily access theme-aware colors
extension ThemeColorsExtension on BuildContext {
  AppColorsTheme get colors {
    final brightness = Theme.of(this).brightness;
    return AppColorsTheme(isDark: brightness == Brightness.dark);
  }

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
