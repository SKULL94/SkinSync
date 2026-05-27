import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/constants/text_styles.dart';
import 'package:skin_sync/core/di/injection_container.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:skin_sync/features/auth/presentation/bloc/onboarding_bloc.dart';
import 'package:skin_sync/features/auth/presentation/widgets/art_header.dart';
import 'package:skin_sync/features/auth/presentation/widgets/gender_card.dart';
import 'package:skin_sync/features/auth/presentation/widgets/primary_button.dart';
import 'package:skin_sync/features/auth/presentation/widgets/progress_indicator.dart';

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
          body: Column(
            children: [
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
                      isLoading: state.status == OnboardingStatus.loading,
                      onGenderSelected: (gender) => context
                          .read<OnboardingBloc>()
                          .add(OnboardingGenderSelected(gender)),
                      onComplete: () => context
                          .read<OnboardingBloc>()
                          .add(const OnboardingCompleteRequested()),
                    ),
                  ],
                ),
              ),
              // Progress indicator (onboarding is step 2 and 3 of 3)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: AuthProgressIndicator(
                    currentStep: state.currentPage + 2,
                    totalSteps: 3,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NAME SCREEN
// ═══════════════════════════════════════════════════════════════════════════
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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ArtHeader(emoji: '👋'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 22, 28, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StringConst.kWhatsYourName,
                  style: AppTextStyles.heading2.copyWith(fontSize: 30),
                ),
                const SizedBox(height: 6),
                Text(
                  StringConst.kPersonalisedInsights,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 22),
                // Name input
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    // border: Border.all(
                    //   color: _isFocused
                    //       ? AppColors.primary
                    //       : AppColors.cardBorder.withValues(alpha: 0.5),
                    //   width: 1.5,
                    // ),
                  ),
                  child: TextField(
                    controller: widget.nameController,
                    focusNode: _focusNode,
                    onChanged: widget.onNameChanged,
                    textCapitalization: TextCapitalization.words,
                    style: AppTextStyles.inputText,
                    decoration: InputDecoration(
                      hintText: StringConst.kYourFirstName,
                      hintStyle: AppTextStyles.inputHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: '${StringConst.kContinue} →',
                  enabled: widget.isValid,
                  onTap: widget.onContinue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GENDER SCREEN
// ═══════════════════════════════════════════════════════════════════════════
class _GenderScreen extends StatelessWidget {
  final String? selectedGender;
  final bool isLoading;
  final ValueChanged<String> onGenderSelected;
  final VoidCallback onComplete;

  const _GenderScreen({
    required this.selectedGender,
    required this.isLoading,
    required this.onGenderSelected,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ArtHeader(emoji: '🌿'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 22, 28, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StringConst.kHowDoYouIdentify,
                  style: AppTextStyles.heading2.copyWith(fontSize: 30),
                ),
                const SizedBox(height: 6),
                Text(
                  StringConst.kHelpsPersonalise,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 22),
                // 2-col gender grid
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
                    const SizedBox(width: 11),
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
                const SizedBox(height: 11),
                GenderCardFull(
                  emoji: '✨',
                  label: StringConst.kNonBinary,
                  isSelected: selectedGender == 'non-binary',
                  onTap: () => onGenderSelected('non-binary'),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: '${StringConst.kCompleteSetup} →',
                  enabled: selectedGender != null && !isLoading,
                  isLoading: isLoading,
                  onTap: onComplete,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
