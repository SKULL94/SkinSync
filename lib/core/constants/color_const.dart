import 'package:flutter/material.dart';

/// AURA Design System Colors
/// Warm, organic, luxurious skincare aesthetic
class AppColors {
  AppColors._();

  // Primary Colors - Terra (Terracotta/Orange)
  static const Color primary = Color(0xFFD4845A); // Terra - main brand color
  static const Color primaryLight = Color(0xFFE5A07A); // Lighter terra
  static const Color primaryDark = Color(0xFFB86E48); // Darker terra

  // Secondary Colors - Sage (Green)
  static const Color sage = Color(0xFF8FA882); // Sage green
  static const Color sageLight = Color(0xFFA8BF9C); // Light sage
  static const Color sageDark = Color(0xFF6B8060); // Dark sage

  // Accent Colors
  static const Color rose = Color(0xFFC49898); // Rose pink
  static const Color amber = Color(0xFFE8A84A); // Amber/gold

  // Background Colors - Warm Beige
  static const Color background = Color(0xFFF2EDE6); // Main bg - warm beige
  static const Color backgroundLight = Color(0xFFF8F5F0); // Lighter beige
  static const Color surface = Color(0xFFFFFFFF); // White for cards
  static const Color surfaceVariant = Color(0xFFFAF7F3); // Off-white

  // Text Colors - Ink (Dark Brown)
  static const Color ink = Color(0xFF2A2118); // Primary text - dark brown
  static const Color textPrimary = Color(0xFF2A2118); // Alias for ink
  static const Color textSecondary = Color(0xFF5C5347); // Secondary text
  static const Color textTertiary = Color(0xFF8A8279); // Tertiary/muted text
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White text on primary
  static const Color textOnDark = Color(0xFFF2EDE6); // Beige text on dark

  // Status Colors
  static const Color success = Color(0xFF8FA882); // Sage green for success
  static const Color warning = Color(0xFFE8A84A); // Amber for warning
  static const Color error = Color(0xFFD4645A); // Warm red
  static const Color info = Color(0xFF5A8FD4); // Blue for info

  // Metric Status Colors (Good/Medium/Low)
  static const Color metricGood = Color(0xFF8FA882); // Sage - Good
  static const Color metricMedium = Color(0xFFE8A84A); // Amber - Medium
  static const Color metricLow = Color(0xFFC49898); // Rose - Low/Needs attention

  // Metric Category Colors
  static const Color metricHydration = Color(0xFF5AA8D4); // Blue for hydration
  static const Color metricOiliness = Color(0xFFE8A84A); // Amber for oiliness
  static const Color metricTexture = Color(0xFFC49898); // Rose for texture
  static const Color metricClarity = Color(0xFF8FA882); // Sage for clarity

  // Card & Border Colors
  static const Color cardBorder = Color(0xFFE5DED4); // Warm border
  static const Color divider = Color(0xFFE5DED4); // Divider
  static const Color chipBackground = Color(0xFFE5DED4); // Chip bg

  // Shadow & Overlay
  static const Color shadow = Color(0x1A2A2118); // 10% ink
  static const Color overlay = Color(0x662A2118); // 40% ink for overlays
  static const Color scrim = Color(0xCC2A2118); // 80% ink for scanning overlay

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1E1B16); // Dark warm
  static const Color darkSurface = Color(0xFF2A2620); // Dark surface
  static const Color darkCardBorder = Color(0xFF3D3830); // Dark border

  // Gradient Colors
  static const Color gradientTerraStart = Color(0xFFD4845A); // Terra
  static const Color gradientTerraEnd = Color(0xFFE8A84A); // Amber
  static const Color gradientSageStart = Color(0xFF8FA882); // Sage
  static const Color gradientSageEnd = Color(0xFFA8BF9C); // Light sage

  // Score Ring Gradient
  static const Color scoreGradientStart = Color(0xFFD4845A); // Terra
  static const Color scoreGradientMiddle = Color(0xFFE8A84A); // Amber
  static const Color scoreGradientEnd = Color(0xFF8FA882); // Sage

  // Navigation
  static const Color navInactive = Color(0xFF8A8279); // Muted
  static const Color navActive = Color(0xFFD4845A); // Terra

  // Glassmorphism
  static const Color glassWhite = Color(0xE6FFFFFF); // 90% white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white
  static const Color glassBackground = Color(0xE6FFFFFF); // 90% white (alias)

  // Legacy color aliases for backward compatibility
  static const Color secondaryLight = Color(0xFFA8BF9C); // Alias for sageLight
  static const Color backgroundSecondary = Color(0xFFF8F5F0); // Alias for backgroundLight
  static const Color backgroundPink = Color(0xFFFAF5F0); // Warm tint
  static const Color backgroundLavender = Color(0xFFF5F0F0); // Warm tint
  static const Color riskLow = Color(0xFF8FA882); // Sage - low risk
  static const Color riskMedium = Color(0xFFE8A84A); // Amber - medium risk
  static const Color riskHigh = Color(0xFFD4645A); // Warm red - high risk
  static const Color buttonOverlay = Color(0xCCD4845A); // 80% terra
}

/// Gradient definitions for the app
class AppGradients {
  AppGradients._();

  // Score ring gradient (terra to amber to sage)
  static const LinearGradient scoreGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.scoreGradientStart,
      AppColors.scoreGradientMiddle,
      AppColors.scoreGradientEnd,
    ],
  );

  // Terra gradient for buttons/accents
  static const LinearGradient terraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      AppColors.amber,
    ],
  );

  // Sage gradient
  static const LinearGradient sageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.sage,
      AppColors.sageLight,
    ],
  );

  // Hero card gradient (dark overlay for text readability)
  static const LinearGradient heroOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000),
      Color(0x80000000),
    ],
  );

  // Scan button gradient
  static const LinearGradient scanButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      AppColors.primaryLight,
    ],
  );

  // Card subtle gradient
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFAF7F3),
    ],
  );
}
