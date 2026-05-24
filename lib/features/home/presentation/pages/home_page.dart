import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/di/injection_container.dart';
import 'package:skin_sync/core/repositories/user_repository.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:skin_sync/core/services/storage_service.dart';
import 'package:skin_sync/features/history/domain/entities/history_entity.dart';
import 'package:skin_sync/features/history/presentation/bloc/history_bloc.dart';
import 'package:skin_sync/features/layout/presentation/bloc/layout_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final userRepository = sl<UserRepository>();
    final storageService = sl<StorageService>();

    // Try Supabase first
    final profile = await userRepository.getCurrentUserProfile();

    if (profile != null && profile.firstName != null) {
      setState(() => _userName = profile.firstName!);
    } else {
      // Fallback to local storage
      final name = storageService.fetch<String>('user_name');
      if (name != null) {
        setState(() => _userName = name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<HistoryBloc>().add(const HistoryLoadRequested());
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top bar: greeting + avatar ──────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: _buildHeader(context),
                ),
                const SizedBox(height: 20),

                // ── Hero card (dark background, full-width minus padding) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildHeroCard(context),
                ),
                const SizedBox(height: 14),

                // ── Score strip ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildScoreStrip(context),
                ),
                const SizedBox(height: 13),

                // ── Disclaimer ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildDisclaimer(),
                ),
                const SizedBox(height: 22),

                // ── Quick Actions ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildSectionHeader('Quick Actions'),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildQuickActions(context),
                ),
                const SizedBox(height: 22),

                // ── Daily Tips ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader('Daily Tips'),
                      Text(
                        'See all',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildDailyTips(),
                const SizedBox(height: 108), // bottom nav clearance
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final displayName = _userName.isNotEmpty ? _userName : 'there';
    final avatarInitial = _userName.isNotEmpty ? _userName[0].toUpperCase() : '?';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: AppColors.textTertiary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              displayName,
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                color: AppColors.textPrimary,
                height: 1,
              ),
            ),
          ],
        ),
        // Avatar circle → navigates to profile
        GestureDetector(
          onTap: () =>
              context.read<LayoutBloc>().add(const LayoutTabChanged(2)),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF0D4C2), // --terral
                  const Color(0xFFEDD8D8), // --rosell
                ],
              ),
              border: Border.all(color: AppColors.cardBorder, width: 2),
            ),
            child: Center(
              child: Text(
                avatarInitial,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HERO CARD — dark with radial glow + dot-grid texture + chip + CTA
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeroCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.skinAnalysisRoute),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.ink, // #2A2118
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Stack(
          children: [
            // Radial glow — top right, terracotta
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Radial glow — bottom left, rose
            Positioned(
              bottom: -60,
              left: -20,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.rose.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Dot-grid texture overlay
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CustomPaint(
                  painter: _DotGridPainter(),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI Analysis chip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pulsing dot
                        _PulsingDot(),
                        const SizedBox(width: 7),
                        Text(
                          'AI ANALYSIS',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Heading
                  Text(
                    'How does your\nskin feel today?',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 27,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFFF2EDE6), // --bg
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 7),
                  // Sub-text
                  Text(
                    'Instant AI-powered analysis with\npersonalised recommendations',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFFF2EDE6).withValues(alpha: 0.55),
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 22),
                  // CTA button
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.flare_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Analyse Skin',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
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

  // ─────────────────────────────────────────────────────────────────────────
  // SCORE STRIP
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildScoreStrip(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      buildWhen: (prev, curr) => prev.histories != curr.histories,
      builder: (context, state) {
        if (state.histories.isEmpty) return _buildEmptyScoreStrip();
        final latest = state.histories.first;
        final score = _calculateOverallScore(latest);
        return _ScoreStripCard(score: score, lastDate: latest.date);
      },
    );
  }

  Widget _buildEmptyScoreStrip() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      child: Row(
        children: [
          // Empty ring
          SizedBox(
            width: 68,
            height: 68,
            child: CustomPaint(
              painter:
                  _ScoreRingPainter(progress: 0, color: AppColors.cardBorder),
              child: Center(
                child: Text(
                  '?',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LAST SKIN SCORE',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'No scan yet',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Scan your skin to get your score',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DISCLAIMER — sage-tinted advisory card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.sage.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.sage.withValues(alpha: 0.22),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.shield_outlined,
              size: 14,
              color: AppColors.sage,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADVISORY ONLY',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.sage,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Aura provides AI-powered insights, not medical advice. We are not medical professionals. Please consult a certified dermatologist for skin concerns.',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textTertiary,
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SECTION HEADER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        fontSize: 19,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // QUICK ACTIONS — 2×2 grid
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                iconWidget: const Icon(Icons.flare_rounded,
                    size: 18, color: AppColors.primary),
                iconBg: const Color(0xFFF0D4C2),
                label: 'New Scan',
                sub: 'Analyse now',
                onTap: () => context.push(AppRoutes.skinAnalysisRoute),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: _QuickActionCard(
                iconWidget:
                    Icon(Icons.show_chart, size: 18, color: AppColors.rose),
                iconBg: const Color(0xFFEDD8D8),
                label: 'History',
                sub: 'View progress',
                onTap: () =>
                    context.read<LayoutBloc>().add(const LayoutTabChanged(1)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                iconWidget: Icon(Icons.water_drop_outlined,
                    size: 18, color: AppColors.sage),
                iconBg: const Color(0xFFD4E3CC),
                label: 'Hydration',
                sub: 'Track intake',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: _QuickActionCard(
                iconWidget: Icon(Icons.person_outline,
                    size: 18, color: AppColors.amber),
                iconBg: const Color(0xFFF5DCA8),
                label: 'Profile',
                sub: 'My details',
                onTap: () =>
                    context.read<LayoutBloc>().add(const LayoutTabChanged(2)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DAILY TIPS — horizontal scroll
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDailyTips() {
    final tips = [
      _TipData(
        icon: Icons.wb_sunny_outlined,
        iconBg: const Color(0xFFF0D4C2),
        iconColor: AppColors.primary,
        text: 'Apply SPF 30+ every morning before going out',
      ),
      _TipData(
        icon: Icons.bedtime_outlined,
        iconBg: const Color(0xFFEDD8D8),
        iconColor: AppColors.rose,
        text: '7–8 hrs sleep powers overnight skin repair',
      ),
      _TipData(
        icon: Icons.eco_outlined,
        iconBg: const Color(0xFFD4E3CC),
        iconColor: AppColors.sage,
        text: 'Antioxidants fight free radicals and slow ageing',
      ),
      _TipData(
        icon: Icons.water_drop_outlined,
        iconBg: const Color(0xFFF5DCA8),
        iconColor: AppColors.amber,
        text: 'Cold water rinse closes pores after cleansing',
      ),
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        clipBehavior: Clip.none,
        itemCount: tips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 11),
        itemBuilder: (_, i) => _TipCard(tip: tips[i]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────
  int _calculateOverallScore(HistoryEntity analysis) {
    try {
      if (analysis.results.isNotEmpty) {
        final topConfidence =
            (analysis.results.first['confidence'] as num?)?.toDouble() ?? 0.5;
        return (50 + (topConfidence * 50)).toInt().clamp(0, 100);
      }
    } catch (_) {}
    return 55;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SCORE STRIP CARD
// ═══════════════════════════════════════════════════════════════════════════
class _ScoreStripCard extends StatelessWidget {
  final int score;
  final DateTime lastDate;

  const _ScoreStripCard({required this.score, required this.lastDate});

  String _formatDate() {
    final now = DateTime.now();
    final diff = now.difference(lastDate);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('MMM d').format(lastDate);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      child: Row(
        children: [
          // Left: label + score + trend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LAST SKIN SCORE',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$score',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 36,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 12, color: AppColors.sage),
                    const SizedBox(width: 3),
                    Text(
                      '10 pts from last scan',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.sage,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Right: score ring
          SizedBox(
            width: 68,
            height: 68,
            child: CustomPaint(
              painter: _ScoreRingPainter(
                progress: score / 100,
                color: AppColors.amber,
                trackColor: AppColors.cardBorder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// QUICK ACTION CARD
// ═══════════════════════════════════════════════════════════════════════════
class _QuickActionCard extends StatelessWidget {
  final Widget iconWidget;
  final Color iconBg;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.iconWidget,
    required this.iconBg,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Center(child: iconWidget),
            ),
            const SizedBox(height: 11),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w300,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DAILY TIP CARD
// ═══════════════════════════════════════════════════════════════════════════
class _TipData {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String text;
  const _TipData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.text,
  });
}

class _TipCard extends StatelessWidget {
  final _TipData tip;
  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 144,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: tip.iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: Icon(tip.icon, size: 15, color: tip.iconColor),
            ),
          ),
          const SizedBox(height: 9),
          Expanded(
            child: Text(
              tip.text,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.textPrimary,
                height: 1.55,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PULSING DOT — animated green dot on hero chip
// ═══════════════════════════════════════════════════════════════════════════
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 1.0, end: 0.35).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 5,
        height: 5,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SCORE RING PAINTER — matches HTML SVG circular progress
// ═══════════════════════════════════════════════════════════════════════════
class _ScoreRingPainter extends CustomPainter {
  final double progress; // 0.0 – 1.0
  final Color color;
  final Color trackColor;

  const _ScoreRingPainter({
    required this.progress,
    required this.color,
    this.trackColor = const Color(0xFFE5DED4),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width - 6) / 2; // stroke-width 6
    const strokeWidth = 5.0;
    const startAngle = -1.5708; // -90°, top

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      0,
      6.2832,
      false,
      Paint()
        ..color = trackColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0) return;

    // Gradient fill arc — amber → terra, matching HTML linearGradient
    final sweepAngle = 6.2832 * progress;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: const [
        Color(0xFFE8A84A), // amber
        Color(0xFFD4845A), // terra
      ],
    ).createShader(rect);

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..shader = gradient
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) =>
      old.progress != progress || old.color != color;
}

// ═══════════════════════════════════════════════════════════════════════════
// DOT GRID PAINTER — matches HTML SVG pattern on hero card (2.5% opacity)
// ═══════════════════════════════════════════════════════════════════════════
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const step = 28.0;

    // Horizontal lines (top-left grid pattern like SVG pattern path "M28 0L0 0 0 28")
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter _) => false;
}
