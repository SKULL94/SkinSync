import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/image_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/di/injection_container.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:skin_sync/features/auth/presentation/bloc/onboarding_bloc.dart';
import 'package:skin_sync/features/auth/presentation/widgets/gender_card.dart';
import 'package:skin_sync/features/auth/presentation/widgets/primary_button.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OnboardingBloc>(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();

  static const int _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.currentPage != current.currentPage,
      listener: (context, state) {
        if (state.status == OnboardingStatus.success) {
          context.go(AppRoutes.layoutRoute);
        }
        if (state.currentPage != _pageController.page?.round()) {
          _animateToPage(state.currentPage);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Progress dots at top
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: _OnboardingProgress(
                    total: _totalPages,
                    current: state.currentPage,
                  ),
                ),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _NameScreen(
                        nameController: _nameController,
                        isValid: state.isNameValid,
                        onNameChanged: (name) => context
                            .read<OnboardingBloc>()
                            .add(OnboardingNameChanged(name)),
                        onContinue: () => context
                            .read<OnboardingBloc>()
                            .add(const OnboardingNextPage()),
                      ),
                      _GenderScreen(
                        selectedGender: state.gender,
                        onGenderSelected: (gender) => context
                            .read<OnboardingBloc>()
                            .add(OnboardingGenderSelected(gender)),
                        onContinue: () => context
                            .read<OnboardingBloc>()
                            .add(const OnboardingNextPage()),
                      ),
                      _DisclaimerScreen(
                        acknowledged: state.disclaimerAcknowledged,
                        isLoading: state.status == OnboardingStatus.loading,
                        onToggle: (val) => context
                            .read<OnboardingBloc>()
                            .add(OnboardingDisclaimerToggled(val)),
                        onComplete: () => context
                            .read<OnboardingBloc>()
                            .add(const OnboardingCompleteRequested()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress dots
// ─────────────────────────────────────────────────────────────────────────────
class _OnboardingProgress extends StatelessWidget {
  final int total;
  final int current;

  const _OnboardingProgress({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.track,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 0 — Name
// ─────────────────────────────────────────────────────────────────────────────
class _NameScreen extends StatefulWidget {
  final TextEditingController nameController;
  final bool isValid;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onContinue;

  const _NameScreen({
    required this.nameController,
    required this.isValid,
    required this.onNameChanged,
    required this.onContinue,
  });

  @override
  State<_NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<_NameScreen> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringConst.kWhatsYourName,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              letterSpacing: -0.28,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            StringConst.kPersonalisedInsights,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 28),

          // Name input
          TextField(
            controller: widget.nameController,
            focusNode: _focusNode,
            onChanged: widget.onNameChanged,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
            decoration: InputDecoration(
              hintText: StringConst.kYourFirstName,
              hintStyle: GoogleFonts.hankenGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.muted2,
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.hairline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.hairline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),

          const SizedBox(height: 24),

          PrimaryButton(
            label: '${StringConst.kContinue} →',
            enabled: widget.isValid,
            onTap: widget.onContinue,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 1 — Gender
// ─────────────────────────────────────────────────────────────────────────────
class _GenderScreen extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String> onGenderSelected;
  final VoidCallback onContinue;

  const _GenderScreen({
    required this.selectedGender,
    required this.onGenderSelected,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringConst.kHowDoYouIdentify,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              letterSpacing: -0.28,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            StringConst.kHelpsPersonalise,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: GenderCard(
                  emoji: '🧑',
                  label: StringConst.kMale,
                  isSelected: selectedGender == 'male',
                  onTap: () => onGenderSelected('male'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GenderCard(
                  emoji: '👩',
                  label: StringConst.kFemale,
                  isSelected: selectedGender == 'female',
                  onTap: () => onGenderSelected('female'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          GenderCardFull(
            emoji: '✨',
            label: StringConst.kNonBinary,
            isSelected: selectedGender == 'non-binary',
            onTap: () => onGenderSelected('non-binary'),
          ),

          const SizedBox(height: 24),

          PrimaryButton(
            label: '${StringConst.kContinue} →',
            enabled: selectedGender != null,
            onTap: onContinue,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 2 — Disclaimer acknowledgement
// ─────────────────────────────────────────────────────────────────────────────
class _DisclaimerScreen extends StatelessWidget {
  final bool acknowledged;
  final bool isLoading;
  final ValueChanged<bool> onToggle;
  final VoidCallback onComplete;

  const _DisclaimerScreen({
    required this.acknowledged,
    required this.isLoading,
    required this.onToggle,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo mark on light background
          Center(
            child: Image.asset(
              ImageConst.markColor,
              width: 56,
              height: 56,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.face_retouching_natural,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            StringConst.kBeforeFirstScan,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              letterSpacing: -0.26,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            StringConst.kDisclaimerIntro,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 24),

          // Full disclaimer card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.hairline, width: 1),
            ),
            child: Text(
              StringConst.kFullDisclaimerText,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textTertiary,
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // "I understand" checkbox row
          GestureDetector(
            onTap: () => onToggle(!acknowledged),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: acknowledged
                        ? AppColors.primary
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: acknowledged
                          ? AppColors.primary
                          : AppColors.hairline,
                      width: 1.5,
                    ),
                  ),
                  child: acknowledged
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    StringConst.kIUnderstand,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          PrimaryButton(
            label: '${StringConst.kContinue} →',
            enabled: acknowledged && !isLoading,
            isLoading: isLoading,
            onTap: onComplete,
          ),
        ],
      ),
    );
  }
}
