import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:skin_sync/core/theme/theme_extension.dart';
import 'package:skin_sync/features/history/domain/entities/history_entity.dart';
import 'package:skin_sync/features/history/presentation/bloc/history_bloc.dart';
import 'package:skin_sync/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:skin_sync/features/home/presentation/bloc/dashboard_event.dart';
import 'package:skin_sync/features/home/presentation/bloc/dashboard_state.dart';
import 'package:skin_sync/features/layout/presentation/bloc/layout_bloc.dart';
import 'package:skin_sync/features/skin_analysis/presentation/bloc/skin_analysis_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // DashboardBloc is provided by LayoutPage
    return const _HomePageContent();
  }
}

class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<DashboardBloc>().add(const RefreshDashboard());
            context.read<HistoryBloc>().add(const HistoryLoadRequested());
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar: greeting + avatar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: _buildHeader(context),
                ),
                const SizedBox(height: 20),

                // Hero card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildHeroCard(context),
                ),
                const SizedBox(height: 14),

                // Score strip
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildScoreStrip(context),
                ),
                const SizedBox(height: 13),

                // Disclaimer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildDisclaimer(),
                ),
                const SizedBox(height: 22),

                // Quick Actions
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

                // Upcoming Reminder
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildSectionHeader('Upcoming'),
                ),
                const SizedBox(height: 12),
                _buildUpcomingReminder(context),
                // Extra padding to clear floating nav bar
                SizedBox(height: 100 + MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (prev, curr) =>
          prev.dashboard?.userName != curr.dashboard?.userName ||
          prev.status != curr.status,
      builder: (context, state) {
        final isLoading = state.status == DashboardStatus.initial ||
            state.status == DashboardStatus.loading;
        final userName = state.dashboard?.userName ?? 'there';
        final avatarInitial = userName.isNotEmpty && userName != 'there'
            ? userName[0].toUpperCase()
            : '?';

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
                if (isLoading)
                  Shimmer.fromColors(
                    baseColor: AppColors.cardBorder,
                    highlightColor: AppColors.background,
                    child: Container(
                      width: 100,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  )
                else
                  Text(
                    userName,
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
            GestureDetector(
              onTap: () => context.push(AppRoutes.personalDetailsRoute),
              child: isLoading
                  ? Shimmer.fromColors(
                      baseColor: AppColors.cardBorder,
                      highlightColor: AppColors.background,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.cardBorder,
                        ),
                      ),
                    )
                  : Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFF0D4C2),
                            Color(0xFFEDD8D8),
                          ],
                        ),
                        border:
                            Border.all(color: AppColors.cardBorder, width: 2),
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
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildHeroCard(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (prev, curr) =>
          prev.dashboard?.heroTitle != curr.dashboard?.heroTitle ||
          prev.dashboard?.heroSubtitle != curr.dashboard?.heroSubtitle,
      builder: (context, state) {
        final heroTitle =
            state.dashboard?.heroTitle ?? 'How does your\nskin feel today?';
        final heroSubtitle = state.dashboard?.heroSubtitle ??
            'Instant AI-powered analysis with\npersonalised recommendations';

        return GestureDetector(
          onTap: () {
            // Reset bloc to start fresh scan
            context.read<SkinAnalysisBloc>().add(const SkinAnalysisReset());
            context.push(AppRoutes.skinAnalysisRoute);
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Stack(
              children: [
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
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CustomPaint(
                      painter: _DotGridPainter(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
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
                            const _PulsingDot(),
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
                      Text(
                        heroTitle,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 27,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFFF2EDE6),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        heroSubtitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color:
                              const Color(0xFFF2EDE6).withValues(alpha: 0.55),
                          height: 1.65,
                        ),
                      ),
                      const SizedBox(height: 22),
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
      },
    );
  }

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
          SizedBox(
            width: 68,
            height: 68,
            child: CustomPaint(
              painter: const _ScoreRingPainter(
                  progress: 0, color: AppColors.cardBorder),
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
                  'Skin Sync provides AI-powered insights, not medical advice. We are not medical professionals. Please consult a certified dermatologist for skin concerns.',
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
                onTap: () {
                  // Reset bloc to start fresh scan
                  context
                      .read<SkinAnalysisBloc>()
                      .add(const SkinAnalysisReset());
                  context.push(AppRoutes.skinAnalysisRoute);
                },
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: _QuickActionCard(
                iconWidget:
                    Icon(Icons.auto_awesome, size: 18, color: AppColors.rose),
                iconBg: const Color(0xFFEDD8D8),
                label: 'AI Tips',
                sub: 'Personalized',
                onTap: () => context.push(AppRoutes.aiTipsRoute),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                iconWidget:
                    Icon(Icons.show_chart, size: 18, color: AppColors.sage),
                iconBg: const Color(0xFFD4E3CC),
                label: 'Trends',
                sub: 'View progress',
                onTap: () => context.push(AppRoutes.trendsRoute),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: _QuickActionCard(
                iconWidget: Icon(Icons.checklist_outlined,
                    size: 18, color: AppColors.amber),
                iconBg: const Color(0xFFF5DCA8),
                label: 'Routine',
                sub: 'Daily care',
                onTap: () => context.push(AppRoutes.routineRoute),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingReminder(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        // Calculate days since last scan
        int daysSinceLastScan = 7;
        if (state.histories.isNotEmpty) {
          final lastScan = state.histories.first.date;
          daysSinceLastScan = DateTime.now().difference(lastScan).inDays;
        }

        // Determine reminder message based on last scan
        String reminderTitle;
        String reminderSubtitle;
        IconData reminderIcon;
        Color reminderColor;

        if (daysSinceLastScan == 0) {
          reminderTitle = 'Great job!';
          reminderSubtitle = 'You scanned today. Next scan tomorrow.';
          reminderIcon = Icons.check_circle_outline;
          reminderColor = AppColors.sage;
        } else if (daysSinceLastScan == 1) {
          reminderTitle = 'Scan reminder';
          reminderSubtitle = 'Time for your daily skin check';
          reminderIcon = Icons.access_time;
          reminderColor = AppColors.amber;
        } else if (daysSinceLastScan <= 3) {
          reminderTitle = 'Don\'t forget!';
          reminderSubtitle = '$daysSinceLastScan days since your last scan';
          reminderIcon = Icons.notification_important_outlined;
          reminderColor = AppColors.amber;
        } else {
          reminderTitle = 'We miss you!';
          reminderSubtitle = '$daysSinceLastScan days since your last scan';
          reminderIcon = Icons.warning_amber_outlined;
          reminderColor = AppColors.rose;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: reminderColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    reminderIcon,
                    size: 24,
                    color: reminderColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminderTitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        reminderSubtitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (daysSinceLastScan > 0)
                  GestureDetector(
                    onTap: () => context
                        .read<LayoutBloc>()
                        .add(const LayoutTabChanged(1)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Scan',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _calculateOverallScore(HistoryEntity analysis) {
    try {
      // Only use AI analysis score - no fallback
      if (analysis.aiAnalysis != null) {
        final aiScore = analysis.aiAnalysis!['overall_score'];
        if (aiScore != null) {
          return (aiScore as num).toInt().clamp(0, 100);
        }
        debugPrint('ERROR: aiAnalysis exists but overall_score is null');
      } else {
        debugPrint('ERROR: aiAnalysis is NULL - cannot calculate score');
      }
    } catch (e) {
      debugPrint('Error calculating score: $e');
    }
    // Return 0 to indicate missing data
    return 0;
  }
}

// Score Strip Card
class _ScoreStripCard extends StatelessWidget {
  final int score;
  final DateTime lastDate;

  const _ScoreStripCard({required this.score, required this.lastDate});

  String _formatDateIST(DateTime date) {
    // Convert to IST (UTC+5:30)
    final ist = date.toUtc().add(const Duration(hours: 5, minutes: 30));
    final now =
        DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    final diff = now.difference(ist);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      // Format as "12 May, 3:45 PM"
      final day = ist.day;
      final month = _monthName(ist.month);
      final hour =
          ist.hour > 12 ? ist.hour - 12 : (ist.hour == 0 ? 12 : ist.hour);
      final minute = ist.minute.toString().padLeft(2, '0');
      final ampm = ist.hour >= 12 ? 'PM' : 'AM';
      return '$day $month, $hour:$minute $ampm';
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  // Get badge info based on score
  ({String label, Color color, Color bgColor, IconData icon}) _getBadgeInfo() {
    if (score == 0) {
      // Missing AI analysis data
      return (
        label: 'No Data',
        color: AppColors.textTertiary,
        bgColor: AppColors.cardBorder.withValues(alpha: 0.3),
        icon: Icons.help_outline_rounded,
      );
    } else if (score >= 80) {
      return (
        label: 'Excellent',
        color: const Color(0xFF2E7D32),
        bgColor: const Color(0xFFE8F5E9),
        icon: Icons.sentiment_very_satisfied_rounded,
      );
    } else if (score >= 60) {
      return (
        label: 'Good',
        color: AppColors.sage,
        bgColor: AppColors.sage.withValues(alpha: 0.12),
        icon: Icons.sentiment_satisfied_rounded,
      );
    } else if (score >= 40) {
      return (
        label: 'Fair',
        color: AppColors.amber,
        bgColor: AppColors.amber.withValues(alpha: 0.12),
        icon: Icons.sentiment_neutral_rounded,
      );
    } else {
      return (
        label: 'Needs Care',
        color: AppColors.rose,
        bgColor: AppColors.rose.withValues(alpha: 0.12),
        icon: Icons.sentiment_dissatisfied_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final badge = _getBadgeInfo();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      child: Row(
        children: [
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$score',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 36,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1,
                      ),
                    ),
                    Text(
                      '/100',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateIST(lastDate),
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Skin Health Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: badge.bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: badge.color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  badge.icon,
                  size: 28,
                  color: badge.color,
                ),
                const SizedBox(height: 4),
                Text(
                  badge.label,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badge.color,
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

// Quick Action Card
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

// Pulsing Dot
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

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

// Score Ring Painter
class _ScoreRingPainter extends CustomPainter {
  final double progress;
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
    final radius = (size.width - 6) / 2;
    const strokeWidth = 5.0;
    const startAngle = -1.5708;

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

    final sweepAngle = 6.2832 * progress;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: const [
        Color(0xFFE8A84A),
        Color(0xFFD4845A),
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

// Dot Grid Painter
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const step = 28.0;

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
