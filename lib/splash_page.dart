import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/app_constants.dart';
import 'package:skin_sync/core/constants/color_const.dart';
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
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Show splash for at least 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final storageService = sl<StorageService>();
    final userRepository = sl<UserRepository>();
    final supabase = Supabase.instance.client;

    // Check Supabase session first (handles returning users)
    final session = supabase.auth.currentSession;
    final supabaseUser = supabase.auth.currentUser;

    if (session != null && supabaseUser != null) {
      // User is authenticated in Supabase
      await storageService.save(AppConstants.userId, supabaseUser.id);

      // Check if user has profile in Supabase (returning user check)
      final profile = await userRepository.getCurrentUserProfile();

      if (profile != null && profile.firstName != null) {
        // Returning user with profile - go to home
        await storageService.save('onboarding_completed', true);
        await storageService.save('user_name', profile.firstName);
        if (profile.gender != null) {
          await storageService.save('user_gender', profile.gender);
        }
        if (mounted) context.go(AppRoutes.layoutRoute);
      } else {
        // Authenticated but no profile - needs onboarding
        if (mounted) context.go(AppRoutes.onboardingRoute);
      }
      return;
    }

    // Not authenticated - go to welcome page
    if (mounted) context.go(AppRoutes.welcomeRoute);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to light icons for dark background
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          // Background decorative orbs
          const _SplashBackground(),

          // Main content - just logo
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Terra Orb
                  AnimatedBuilder(
                    animation: _floatAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnimation.value),
                        child: child,
                      );
                    },
                    child: const _TerraOrb(),
                  ),

                  const SizedBox(height: 44),

                  // Brand wordmark
                  Text(
                    'Skin Sync',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 42,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: AppColors.background,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    'YOUR SKIN AI COMPANION',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primary,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Background with decorative gradient orbs
class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-left terra gradient orb
        Positioned(
          top: -120,
          left: -120,
          child: Container(
            width: 480,
            height: 480,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.14),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.65],
              ),
            ),
          ),
        ),
        // Bottom-right rose gradient orb
        Positioned(
          bottom: -80,
          right: -80,
          child: Container(
            width: 360,
            height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.rose.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.65],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Terra gradient orb with rings
class _TerraOrb extends StatelessWidget {
  const _TerraOrb();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      height: 148,
      child: CustomPaint(
        painter: _TerraOrbPainter(),
      ),
    );
  }
}

class _TerraOrbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Main gradient orb
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.24, -0.36),
        radius: 0.7,
        colors: const [
          Color(0xFFF0D4C2), // Light terra
          Color(0xFFD4845A), // Terra
          Color(0xFFC06E44), // Darker terra
          Color(0xFF7A3E22), // Deep terra
        ],
        stops: const [0.0, 0.3, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius - 1, gradientPaint);

    // Highlight ellipse
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18);

    canvas.save();
    canvas.translate(size.width * 0.38, size.height * 0.35);
    canvas.rotate(-0.44); // -25 degrees
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 44, height: 28),
      highlightPaint,
    );
    canvas.restore();

    // Inner rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    ringPaint.color = Colors.white.withValues(alpha: 0.08);
    canvas.drawCircle(center, radius * 0.74, ringPaint);

    ringPaint.color = Colors.white.withValues(alpha: 0.05);
    canvas.drawCircle(center, radius * 0.54, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
