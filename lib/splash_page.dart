import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/app_constants.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/image_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/repositories/user_repository.dart';
import 'package:skin_sync/core/services/storage_service.dart';
import 'package:skin_sync/core/di/injection_container.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    final storageService = sl<StorageService>();
    final userRepository = sl<UserRepository>();
    final supabase = Supabase.instance.client;

    final session = supabase.auth.currentSession;
    final supabaseUser = supabase.auth.currentUser;

    if (session != null && supabaseUser != null) {
      await storageService.save(AppConstants.userId, supabaseUser.id);

      final profile = await userRepository.getCurrentUserProfile();

      if (profile != null && profile.firstName != null) {
        await storageService.save('onboarding_completed', true);
        await storageService.save('user_name', profile.firstName);
        if (profile.gender != null) {
          await storageService.save('user_gender', profile.gender);
        }
        if (mounted) context.go(AppRoutes.layoutRoute);
      } else {
        if (mounted) context.go(AppRoutes.onboardingRoute);
      }
      return;
    }

    if (mounted) context.go(AppRoutes.welcomeRoute);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.deepStart, AppColors.deepEnd],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Logo mark
                Image.asset(
                  ImageConst.markLight,
                  width: 96,
                  height: 96,
                  errorBuilder: (_, __, ___) => const _FallbackMark(),
                ),

                const SizedBox(height: 28),

                // Wordmark: "Skin" white + "sight" accent-bright
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Skin',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.32,
                        ),
                      ),
                      TextSpan(
                        text: 'sight',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentBright,
                          letterSpacing: -0.32,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  StringConst.kTagline,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.55),
                    letterSpacing: 0.2,
                  ),
                ),

                const Spacer(flex: 3),

                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackMark extends StatelessWidget {
  const _FallbackMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: CustomPaint(painter: _MarkPainter()),
    );
  }
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(center.dx, center.dy - r * 0.2),
          width: r * 1.1,
          height: r * 1.1),
      3.14,
      3.14,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(center.dx, center.dy + r * 0.2),
          width: r * 1.1,
          height: r * 1.1),
      0,
      3.14,
      false,
      paint,
    );

    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - r * 0.7, center.dy), 3, dotPaint);
    canvas.drawCircle(Offset(center.dx + r * 0.7, center.dy), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
