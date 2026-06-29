import 'package:flutter/material.dart';

/// Skinsight Design System Colors
class AppColors {
  AppColors._();

  // ── Neutrals ────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF4F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color hairline = Color(0xFFEAEFEC);
  static const Color hairlineSoft = Color(0xFFF1F5F3);
  static const Color track = Color(0xFFE6EDE9);

  // Text / ink
  static const Color ink = Color(0xFF0E1A15);
  static const Color textPrimary = Color(0xFF0E1A15);
  static const Color textSecondary = Color(0xFF5E6E67);
  static const Color textTertiary = Color(0xFF6E7C75);
  static const Color muted = Color(0xFF8A988F);
  static const Color muted2 = Color(0xFF9AA8A1);
  static const Color faint = Color(0xFFAEBBB4);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFF4F7F5);

  // ── Primary — Emerald ───────────────────────────────────────────────────
  static const Color primary = Color(0xFF12A56C);
  static const Color primaryLight = Color(0xFF1FBE7B);
  static const Color primaryDark = Color(0xFF0E9E63);
  static const Color primaryTint = Color(0xFFE2F4EC);
  static const Color primaryTintInk = Color(0xFF0E8255);

  // Deep hero surfaces (score card, splash, sign-in header)
  static const Color deepStart = Color(0xFF0F5841);
  static const Color deepEnd = Color(0xFF0A3A2C);
  static const Color deepCore = Color(0xFF0B3326);
  static const Color accentBright = Color(0xFF3FE6A0);

  // ── Status ──────────────────────────────────────────────────────────────
  static const Color good = Color(0xFF15B277);
  static const Color goodTint = Color(0xFFE2F4EC);
  static const Color goodTintInk = Color(0xFF0E8255);
  static const Color warn = Color(0xFFE8A33D);
  static const Color warnTint = Color(0xFFFBF0DB);
  static const Color warnTintInk = Color(0xFF9A6E1F);
  static const Color alert = Color(0xFFF2664B);
  static const Color alertTint = Color(0xFFFCE6E1);
  static const Color alertTintInk = Color(0xFFC24631);

  // ── Metric → score color rule ────────────────────────────────────────────
  // ≥60 → good, 45–59 → warn, <45 → alert
  static const Color metricGood = good;
  static const Color metricMedium = warn;
  static const Color metricLow = alert;
  static const Color metricHydration = Color(0xFF5A8FD4);
  static const Color metricOiliness = warn;
  static const Color metricTexture = alert;
  static const Color metricClarity = good;

  // ── Dark theme ───────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0B1510);
  static const Color darkSurface = Color(0xFF162018);
  static const Color darkCardBorder = Color(0xFF1E3028);

  // ── Navigation ──────────────────────────────────────────────────────────
  static const Color navInactive = faint;
  static const Color navActive = primary;

  // ── Glass / overlay ─────────────────────────────────────────────────────
  static const Color glassWhite = Color(0xE6FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassBackground = Color(0xE6FFFFFF);
  static const Color shadow = Color(0x0D0E1A15);
  static const Color overlay = Color(0x660E1A15);
  static const Color scrim = Color(0xCC0E1A15);

  // ── Legacy aliases (kept so existing screens compile unchanged) ──────────
  static const Color sage = primary;
  static const Color sageLight = primaryLight;
  static const Color sageDark = deepStart;
  static const Color amber = warn;
  static const Color rose = alert;
  static const Color cardBorder = hairline;
  static const Color divider = hairline;
  static const Color chipBackground = primaryTint;
  static const Color backgroundLight = background;
  static const Color backgroundSecondary = background;
  static const Color backgroundPink = primaryTint;
  static const Color backgroundLavender = track;
  static const Color surfaceVariant = hairlineSoft;
  static const Color success = good;
  static const Color warning = warn;
  static const Color error = alert;
  static const Color info = Color(0xFF5A8FD4);
  static const Color riskLow = good;
  static const Color riskMedium = warn;
  static const Color riskHigh = alert;
  static const Color buttonOverlay = Color(0xCC12A56C);
  static const Color primaryContainer = primaryTint;
  static const Color scoreGradientStart = good;
  static const Color scoreGradientMiddle = primaryLight;
  static const Color scoreGradientEnd = accentBright;
  static const Color gradientTerraStart = primaryLight;
  static const Color gradientTerraEnd = primaryDark;
  static const Color gradientSageStart = primary;
  static const Color gradientSageEnd = primaryLight;
}

/// Gradient definitions
class AppGradients {
  AppGradients._();

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryLight, AppColors.primaryDark],
  );

  static const LinearGradient deepGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.deepStart, AppColors.deepEnd],
  );

  static const LinearGradient scoreGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.good, AppColors.accentBright],
  );

  static const LinearGradient terraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryLight, AppColors.primaryDark],
  );

  static const LinearGradient sageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryLight],
  );

  static const LinearGradient heroOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0x80000000)],
  );

  static const LinearGradient scanButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryLight, AppColors.primaryDark],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F3)],
  );
}
