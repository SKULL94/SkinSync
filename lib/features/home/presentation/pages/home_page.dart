import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
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
    return const _HomeContent();
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                // Greeting header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: _HomeHeader(),
                ),

                const SizedBox(height: 20),

                // Deep-emerald hero score card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _HeroScoreCard(),
                ),

                const SizedBox(height: 14),

                // "Start a new scan" CTA
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _StartScanButton(),
                ),

                const SizedBox(height: 12),

                // Quiet disclaimer
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: _QuietDisclaimer(),
                ),

                const SizedBox(height: 22),

                // Quick Actions
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: _SectionHeader(title: StringConst.kQuickActions),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _QuickActionsGrid(),
                ),

                const SizedBox(height: 22),

                // Upcoming reminder
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: _SectionHeader(title: 'Upcoming'),
                ),
                const SizedBox(height: 12),
                _UpcomingReminder(),

                SizedBox(
                    height: 100 + MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Greeting header
// ─────────────────────────────────────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return StringConst.kGoodMorning;
    if (h < 17) return StringConst.kGoodAfternoon;
    return StringConst.kGoodEvening;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (p, c) =>
          p.dashboard?.userName != c.dashboard?.userName ||
          p.dashboard?.avatarUrl != c.dashboard?.avatarUrl ||
          p.status != c.status,
      builder: (context, state) {
        final loading = state.status == DashboardStatus.initial ||
            state.status == DashboardStatus.loading;
        final userName = state.dashboard?.userName ?? StringConst.kDefaultUserName;
        final avatarUrl = state.dashboard?.avatarUrl;
        final initial = userName.isNotEmpty && userName != StringConst.kDefaultUserName
            ? userName[0].toUpperCase()
            : '?';

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                loading
                    ? Shimmer.fromColors(
                        baseColor: AppColors.hairline,
                        highlightColor: AppColors.background,
                        child: Container(
                          width: 100,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.hairline,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      )
                    : Text(
                        userName,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          letterSpacing: -0.24,
                          height: 1,
                        ),
                      ),
              ],
            ),
            GestureDetector(
              onTap: () => context.push(AppRoutes.personalDetailsRoute),
              child: loading
                  ? Shimmer.fromColors(
                      baseColor: AppColors.hairline,
                      highlightColor: AppColors.background,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.hairline,
                        ),
                      ),
                    )
                  : _Avatar(url: avatarUrl, initial: initial),
            ),
          ],
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String initial;

  const _Avatar({this.url, required this.initial});

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      final local = !url!.startsWith('http');
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.hairline, width: 2),
        ),
        child: ClipOval(
          child: local
              ? Image.file(File(url!), fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _InitialAvatar(initial: initial))
              : CachedNetworkImage(
                  imageUrl: url!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _InitialAvatar(initial: initial),
                  errorWidget: (_, __, ___) => _InitialAvatar(initial: initial),
                ),
        ),
      );
    }
    return _InitialAvatar(initial: initial);
  }
}

class _InitialAvatar extends StatelessWidget {
  final String initial;

  const _InitialAvatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryTint,
        border: Border.all(color: AppColors.hairline, width: 2),
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Deep-emerald hero score card
// ─────────────────────────────────────────────────────────────────────────────
class _HeroScoreCard extends StatelessWidget {
  int _score(HistoryEntity h) {
    try {
      final s = h.aiAnalysis?['overall_score'];
      if (s != null) return (s as num).toInt().clamp(0, 100);
    } catch (_) {}
    return 0;
  }

  String _condition(int score) {
    if (score >= 75) return 'Clear';
    if (score >= 60) return 'Mild concerns';
    if (score >= 45) return 'Moderate concerns';
    return 'Significant concerns';
  }

  Color _conditionColor(int score) {
    if (score >= 60) return AppColors.good;
    if (score >= 45) return AppColors.warn;
    return AppColors.alert;
  }

  Map<String, int> _metrics(HistoryEntity h) {
    final m = h.aiAnalysis?['metrics'] as Map<String, dynamic>?;
    if (m == null) return {};
    int _v(dynamic v) {
      if (v is int) return v.clamp(0, 100);
      if (v is double) return v.round().clamp(0, 100);
      if (v is String) return (int.tryParse(v) ?? 0).clamp(0, 100);
      return 0;
    }

    return {
      StringConst.kHydrationMetric: _v(m['hydration']),
      StringConst.kTextureMetric: _v(m['texture']),
      StringConst.kClarityMetric: _v(m['clarity']),
    };
  }

  String _scoreDate(DateTime d) {
    try {
      return DateFormat('MMM d').format(d);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      buildWhen: (p, c) => p.histories != c.histories || p.status != c.status,
      builder: (context, state) {
        final loading = state.status == HistoryStatus.loading ||
            state.status == HistoryStatus.initial;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.deepStart, AppColors.deepEnd],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepEnd.withValues(alpha: 0.45),
                blurRadius: 32,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Subtle dot grid
                Positioned.fill(
                  child: CustomPaint(painter: _DeepDotGrid()),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: loading
                      ? _HeroLoadingState()
                      : state.histories.isEmpty
                          ? _HeroEmptyState()
                          : _HeroLoadedState(
                              score: _score(state.histories.first),
                              condition: _condition(_score(state.histories.first)),
                              conditionColor: _conditionColor(_score(state.histories.first)),
                              scoreDate: _scoreDate(state.histories.first.date),
                              metrics: _metrics(state.histories.first),
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

class _HeroLoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.1),
      highlightColor: Colors.white.withValues(alpha: 0.2),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 188,
            height: 188,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Text(
          'Today\'s skin score',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.55),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 32),
        // Empty ring
        SizedBox(
          width: 188,
          height: 188,
          child: CustomPaint(
            painter: const _ScoreRingPainter(progress: 0, isEmpty: true),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '—',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  Text(
                    'OUT OF 100',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.3),
                      letterSpacing: 0.10 * 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Take your first scan',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'See your skin score and metrics',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _HeroLoadedState extends StatelessWidget {
  final int score;
  final String condition;
  final Color conditionColor;
  final String scoreDate;
  final Map<String, int> metrics;

  const _HeroLoadedState({
    required this.score,
    required this.condition,
    required this.conditionColor,
    required this.scoreDate,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Label row
        Text(
          scoreDate.isEmpty
              ? 'Today\'s skin score'
              : 'Today\'s skin score · $scoreDate',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.55),
            letterSpacing: 0.2,
          ),
        ),

        const SizedBox(height: 20),

        // Score ring
        SizedBox(
          width: 188,
          height: 188,
          child: CustomPaint(
            painter: _ScoreRingPainter(progress: score / 100.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$score',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1,
                      letterSpacing: -0.56,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'OUT OF 100',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.55),
                      letterSpacing: 0.10 * 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Condition chip
        _ConditionChip(label: condition, color: conditionColor),

        // Metric tiles (if data available)
        if (metrics.isNotEmpty) ...[
          const SizedBox(height: 20),
          _MetricTilesRow(metrics: metrics),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Condition chip
// ─────────────────────────────────────────────────────────────────────────────
class _ConditionChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ConditionChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Metric tiles row (inside hero card)
// ─────────────────────────────────────────────────────────────────────────────
class _MetricTilesRow extends StatelessWidget {
  final Map<String, int> metrics;

  const _MetricTilesRow({required this.metrics});

  Color _metricColor(int v) {
    if (v >= 60) return AppColors.accentBright;
    if (v >= 45) return AppColors.warn;
    return AppColors.alert;
  }

  @override
  Widget build(BuildContext context) {
    final entries = metrics.entries.take(3).toList();
    return Row(
      children: entries.asMap().entries.map((e) {
        final idx = e.key;
        final entry = e.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: idx == 0 ? 0 : 8),
            child: _MetricTile(
              label: entry.key,
              value: entry.value,
              color: _metricColor(entry.value),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          // Track bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.deepCore,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value / 100.0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(999),
                    ),
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
// Start a new scan button
// ─────────────────────────────────────────────────────────────────────────────
class _StartScanButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SkinAnalysisBloc>().add(const SkinAnalysisReset());
        context.push(AppRoutes.skinAnalysisRoute);
      },
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryLight, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.30),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.center_focus_weak_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 9),
            Text(
              StringConst.kAnalyseSkin,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quiet disclaimer one-liner
// ─────────────────────────────────────────────────────────────────────────────
class _QuietDisclaimer extends StatelessWidget {
  const _QuietDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Text(
      StringConst.kNotMedicalDiagnosis,
      style: GoogleFonts.hankenGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.muted,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        letterSpacing: -0.17,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Actions 2×2 grid
// ─────────────────────────────────────────────────────────────────────────────
class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.center_focus_weak_rounded,
                iconColor: AppColors.primary,
                iconBg: AppColors.primaryTint,
                label: StringConst.kNewScan,
                sub: StringConst.kAnalyseNow,
                onTap: () {
                  context.read<SkinAnalysisBloc>().add(const SkinAnalysisReset());
                  context.push(AppRoutes.skinAnalysisRoute);
                },
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.auto_awesome_outlined,
                iconColor: AppColors.warn,
                iconBg: AppColors.warnTint,
                label: 'AI Tips',
                sub: 'Personalised',
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
                icon: Icons.show_chart_rounded,
                iconColor: AppColors.primary,
                iconBg: AppColors.primaryTint,
                label: 'Trends',
                sub: StringConst.kViewProgress,
                onTap: () => context.push(AppRoutes.trendsRoute),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.checklist_rounded,
                iconColor: AppColors.warn,
                iconBg: AppColors.warnTint,
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
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.iconColor,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.hairline, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x050E1A15),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Upcoming reminder
// ─────────────────────────────────────────────────────────────────────────────
class _UpcomingReminder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        final days = state.histories.isEmpty
            ? 7
            : DateTime.now().difference(state.histories.first.date).inDays;

        final (String title, String sub, IconData icon, Color color) = days == 0
            ? ('Great job!', 'You scanned today — next scan tomorrow.',
                Icons.check_circle_outline_rounded, AppColors.good)
            : days <= 1
                ? ('Scan reminder', 'Time for your daily skin check',
                    Icons.access_time_rounded, AppColors.warn)
                : days <= 3
                    ? ('Don\'t forget!', '$days days since your last scan',
                        Icons.notifications_outlined, AppColors.warn)
                    : ('We miss you!', '$days days since your last scan',
                        Icons.warning_amber_rounded, AppColors.alert);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.hairline, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 22, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (days > 0)
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
                        style: GoogleFonts.hankenGrotesk(
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Score Ring CustomPainter (188px, accentBright fill on deepCore track)
// ─────────────────────────────────────────────────────────────────────────────
class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final bool isEmpty;

  const _ScoreRingPainter({required this.progress, this.isEmpty = false});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width - 14) / 2;
    const strokeWidth = 12.0;
    const startAngle = -math.pi / 2;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = AppColors.deepCore
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    if (isEmpty || progress <= 0) return;

    final sweepAngle = math.pi * 2 * progress;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Accent-bright fill with a subtle gradient
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle,
          colors: const [AppColors.primaryLight, AppColors.accentBright],
        ).createShader(rect)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) =>
      old.progress != progress || old.isEmpty != isEmpty;
}

// ─────────────────────────────────────────────────────────────────────────────
// Subtle dot grid for hero card background
// ─────────────────────────────────────────────────────────────────────────────
class _DeepDotGrid extends CustomPainter {
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
  bool shouldRepaint(_DeepDotGrid _) => false;
}
