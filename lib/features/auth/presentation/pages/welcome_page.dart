import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/image_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:skin_sync/features/auth/presentation/bloc/welcome_bloc.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WelcomeBloc(),
      child: const _CarouselView(),
    );
  }
}

class _CarouselView extends StatefulWidget {
  const _CarouselView();

  @override
  State<_CarouselView> createState() => _CarouselViewState();
}

class _CarouselViewState extends State<_CarouselView> {
  final PageController _pageController = PageController();

  static const _slides = [
    _SlideData(
      imagePath: ImageConst.carouselScan,
      chip: StringConst.kSlide1Chip,
      headline: StringConst.kSlide1Headline,
      body: StringConst.kSlide1Body,
    ),
    _SlideData(
      imagePath: ImageConst.carousel2,
      chip: StringConst.kSlide2Chip,
      headline: StringConst.kSlide2Headline,
      body: StringConst.kSlide2Body,
    ),
    _SlideData(
      imagePath: ImageConst.carousel3,
      chip: StringConst.kSlide3Chip,
      headline: StringConst.kSlide3Headline,
      body: StringConst.kSlide3Body,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext(int currentPage) {
    if (currentPage < _slides.length - 1) {
      _pageController.animateToPage(
        currentPage + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go(AppRoutes.signInRoute);
    }
  }

  void _onSkip() {
    context.go(AppRoutes.signInRoute);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<WelcomeBloc, WelcomeState>(
          builder: (context, state) {
            final currentPage = state.currentPage;
            final isLast = currentPage == _slides.length - 1;

            return Column(
              children: [
                // Top bar: page dots + skip
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PageDots(
                        count: _slides.length,
                        current: currentPage,
                      ),
                      if (!isLast)
                        GestureDetector(
                          onTap: _onSkip,
                          child: Text(
                            StringConst.kSkip,
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Slide content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) => context
                        .read<WelcomeBloc>()
                        .add(WelcomePageChanged(page)),
                    itemCount: _slides.length,
                    itemBuilder: (context, index) =>
                        _SlideCard(data: _slides[index]),
                  ),
                ),

                // Bottom CTA
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: _CtaButton(
                    label: isLast ? StringConst.kGetStarted : StringConst.kNext,
                    isLast: isLast,
                    onTap: () => _onNext(currentPage),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page dot indicator
// ─────────────────────────────────────────────────────────────────────────────
class _PageDots extends StatelessWidget {
  final int count;
  final int current;

  const _PageDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(right: 6),
          width: active ? 22 : 6,
          height: 6,
          decoration: BoxDecoration(
            color:
                active ? AppColors.primary : AppColors.track,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single carousel slide
// ─────────────────────────────────────────────────────────────────────────────
class _SlideCard extends StatelessWidget {
  final _SlideData data;

  const _SlideCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Illustration
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                data.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryTint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Image.asset(
                      ImageConst.markColor,
                      width: 64,
                      height: 64,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.face_retouching_natural,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Feature chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              data.chip,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryTintInk,
                letterSpacing: 0.11 * 11,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Benefit headline
          Text(
            data.headline,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              height: 1.2,
              letterSpacing: -0.26,
            ),
          ),

          const SizedBox(height: 10),

          // Body
          Text(
            data.body,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
              height: 1.55,
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CTA button
// ─────────────────────────────────────────────────────────────────────────────
class _CtaButton extends StatelessWidget {
  final String label;
  final bool isLast;
  final VoidCallback onTap;

  const _CtaButton({
    required this.label,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: isLast
              ? const LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primaryDark],
                )
              : null,
          color: isLast ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: isLast
              ? null
              : Border.all(color: AppColors.hairline, width: 1.5),
          boxShadow: isLast
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isLast ? Colors.white : AppColors.ink,
              ),
            ),
            if (!isLast) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: AppColors.ink,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slide data model
// ─────────────────────────────────────────────────────────────────────────────
class _SlideData {
  final String imagePath;
  final String chip;
  final String headline;
  final String body;

  const _SlideData({
    required this.imagePath,
    required this.chip,
    required this.headline,
    required this.body,
  });
}
