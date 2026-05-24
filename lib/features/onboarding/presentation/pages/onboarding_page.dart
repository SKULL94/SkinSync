import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/di/injection_container.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:skin_sync/core/services/storage_service.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  final _nameController = TextEditingController();
  String? _selectedGender;
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_nameController.text.trim().isEmpty) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _completeSetup() async {
    if (_selectedGender == null) return;
    final storageService = sl<StorageService>();
    await storageService.save('user_name', _nameController.text.trim());
    await storageService.save('user_gender', _selectedGender);
    await storageService.save('onboarding_completed', true);
    if (mounted) context.go(AppRoutes.layoutRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                _NameScreen(
                  nameController: _nameController,
                  onContinue: _goToNextPage,
                  onChanged: () => setState(() {}),
                ),
                _GenderScreen(
                  selectedGender: _selectedGender,
                  onGenderSelected: (g) => setState(() => _selectedGender = g),
                  onComplete: _completeSetup,
                ),
              ],
            ),
          ),
          // ── Progress indicator (3 pills) ──
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (i) {
                  final isActive = i == _currentPage;
                  final isDone = i < _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: (isDone || isActive) ? 32 : 24,
                    height: 3,
                    decoration: BoxDecoration(
                      color: (isDone || isActive)
                          ? AppColors.primary
                          : AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NAME SCREEN
// ═══════════════════════════════════════════════════════════════════════════
class _NameScreen extends StatelessWidget {
  final TextEditingController nameController;
  final VoidCallback onContinue;
  final VoidCallback onChanged;

  const _NameScreen({
    required this.nameController,
    required this.onContinue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isValid = nameController.text.trim().isNotEmpty;

    return Column(
      children: [
        // ── Dark art header (230px) ──────────────────────────────────
        _ArtHeader(emoji: '👋'),

        // ── Body ────────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 22, 28, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "What's your\nname?",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Personalised insights crafted just for you',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textTertiary,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 22),

                // Name input
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: nameController.text.isNotEmpty
                          ? AppColors.primary
                          : AppColors.cardBorder,
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: nameController,
                    onChanged: (_) => onChanged(),
                    textCapitalization: TextCapitalization.words,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Your first name',
                      hintStyle: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Continue button
                _PrimaryButton(
                  label: 'Continue →',
                  enabled: isValid,
                  onTap: onContinue,
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
  final Function(String) onGenderSelected;
  final VoidCallback onComplete;

  const _GenderScreen({
    required this.selectedGender,
    required this.onGenderSelected,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Dark art header ──────────────────────────────────────────
        _ArtHeader(emoji: '🌿'),

        // ── Body ────────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 22, 28, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How do you\nidentify?',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Helps us personalise your skin analysis',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textTertiary,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 22),

                // 2-col gender grid
                Row(
                  children: [
                    Expanded(
                      child: _GenderCard(
                        emoji: '🧑',
                        label: 'Male',
                        isSelected: selectedGender == 'male',
                        onTap: () => onGenderSelected('male'),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: _GenderCard(
                        emoji: '👩',
                        label: 'Female',
                        isSelected: selectedGender == 'female',
                        onTap: () => onGenderSelected('female'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),

                // Full-width non-binary option
                _GenderCardFull(
                  emoji: '✨',
                  label: 'Non-binary / Prefer not to say',
                  isSelected: selectedGender == 'non-binary',
                  onTap: () => onGenderSelected('non-binary'),
                ),
                const SizedBox(height: 20),

                _PrimaryButton(
                  label: 'Complete Setup →',
                  enabled: selectedGender != null,
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

// ═══════════════════════════════════════════════════════════════════════════
// SHARED: ART HEADER — dark background, 230px, ambient circles + emoji
// ═══════════════════════════════════════════════════════════════════════════
class _ArtHeader extends StatelessWidget {
  final String emoji;
  const _ArtHeader({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      width: double.infinity,
      color: const Color(0xFF2A2118), // --ink
      child: Stack(
        children: [
          // Terracotta radial — top left
          Positioned(
            top: -30,
            left: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Rose radial — bottom right
          Positioned(
            bottom: -50,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.rose.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Outline ring
          Positioned(
            top: 40,
            left: MediaQuery.of(context).size.width / 2 - 60,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          // Concentric rings for texture
          Positioned(
            top: 60,
            left: MediaQuery.of(context).size.width / 2 - 80,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.04),
                ),
              ),
            ),
          ),
          // Wave line SVG-equivalent: two curved decorative lines
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 230),
            painter: _WaveLinePainter(),
          ),
          // Emoji centered bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Wave line painter — replicates the SVG wave path lines in onboard art
class _WaveLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Wave 1 — y ~ 120
    final path1 = Path();
    path1.moveTo(0, 120);
    path1.quadraticBezierTo(size.width / 2, 80, size.width, 120);
    canvas.drawPath(path1, paint);

    // Wave 2 — y ~ 150
    final paint2 = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.05)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    final path2 = Path();
    path2.moveTo(0, 150);
    path2.quadraticBezierTo(size.width / 2, 110, size.width, 150);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_WaveLinePainter _) => false;
}

// ═══════════════════════════════════════════════════════════════════════════
// GENDER CARD — square (2-col)
// ═══════════════════════════════════════════════════════════════════════════
class _GenderCard extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Checkmark badge top-right when selected
            if (isSelected)
              Positioned(
                top: -9,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: const Center(
                    child: Text(
                      '✓',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 30)),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GENDER CARD FULL — non-binary full-width
// ═══════════════════════════════════════════════════════════════════════════
class _GenderCardFull extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCardFull({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Center(
                  child: Text(
                    '✓',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PRIMARY BUTTON — terracotta, full-width
// ═══════════════════════════════════════════════════════════════════════════
class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
