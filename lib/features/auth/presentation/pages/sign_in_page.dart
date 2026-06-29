import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/image_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:skin_sync/core/utils/snackbar_helper.dart';
import 'package:skin_sync/features/auth/presentation/bloc/auth_bloc.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Emerald header ────────────────────────────────────────────────
          _SignInHeader(),

          // ── Auth options ─────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    StringConst.kSignInHeadline,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      letterSpacing: -0.24,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    StringConst.kSignInSubtitle,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 36),

                  // Continue with Apple
                  _AuthButton(
                    label: StringConst.kContinueWithApple,
                    icon: Icons.apple,
                    style: _AuthButtonStyle.dark,
                    onTap: () => SnackbarHelper.showInfo(
                      context,
                      StringConst.kAuthComingSoon,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Continue with Google
                  _AuthButton(
                    label: StringConst.kContinueWithGoogle,
                    svgLetter: 'G',
                    style: _AuthButtonStyle.light,
                    onTap: () => SnackbarHelper.showInfo(
                      context,
                      StringConst.kAuthComingSoon,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(
                          child: Divider(color: AppColors.hairline, thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          StringConst.kOrDivider,
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                      const Expanded(
                          child: Divider(color: AppColors.hairline, thickness: 1)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Continue with phone
                  _AuthButton(
                    label: StringConst.kContinueWithPhone,
                    icon: Icons.phone_android_outlined,
                    style: _AuthButtonStyle.light,
                    onTap: () {
                      context.read<AuthBloc>().add(const AuthResetState());
                      context.go(AppRoutes.authRoute);
                    },
                  ),

                  const SizedBox(height: 28),

                  // Terms / Privacy
                  _TermsLine(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Emerald header section
// ─────────────────────────────────────────────────────────────────────────────
class _SignInHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(24, topPadding + 32, 24, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.deepStart, AppColors.deepEnd],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Image.asset(
            ImageConst.markLight,
            width: 72,
            height: 72,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.face_retouching_natural,
              size: 72,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Skin',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.26,
                  ),
                ),
                TextSpan(
                  text: 'sight',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentBright,
                    letterSpacing: -0.26,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth method button
// ─────────────────────────────────────────────────────────────────────────────
enum _AuthButtonStyle { dark, light }

class _AuthButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? svgLetter;
  final _AuthButtonStyle style;
  final VoidCallback onTap;

  const _AuthButton({
    required this.label,
    required this.style,
    required this.onTap,
    this.icon,
    this.svgLetter,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = style == _AuthButtonStyle.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isDark ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: isDark
              ? null
              : Border.all(color: AppColors.hairline, width: 1.5),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: isDark ? Colors.white : AppColors.ink,
              ),
              const SizedBox(width: 10),
            ] else if (svgLetter != null) ...[
              _GoogleLetterIcon(isDark: isDark),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleLetterIcon extends StatelessWidget {
  final bool isDark;

  const _GoogleLetterIcon({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? Colors.white : AppColors.primaryTint,
        shape: BoxShape.circle,
      ),
      child: Text(
        'G',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Terms / Privacy line
// ─────────────────────────────────────────────────────────────────────────────
class _TermsLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.hankenGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.muted,
          height: 1.6,
        ),
        children: [
          const TextSpan(text: 'By continuing you agree to our '),
          TextSpan(
            text: 'Terms',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const TextSpan(text: ' & '),
          TextSpan(
            text: 'Privacy Policy',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
