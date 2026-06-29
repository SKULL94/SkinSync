import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:skin_sync/core/utils/snackbar_helper.dart';
import 'package:skin_sync/features/history/domain/entities/history_entity.dart';
import 'package:skin_sync/features/history/presentation/bloc/history_bloc.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<HistoryBloc, HistoryState>(
          listenWhen: (p, c) => p.status != c.status,
          listener: (context, state) {
            if (state.status == HistoryStatus.failure &&
                state.errorMessage != null) {
              SnackbarHelper.showError(context, state.errorMessage!);
            }
            if (state.status == HistoryStatus.deleted) {
              SnackbarHelper.showSuccess(
                  context, StringConst.kAnalysisDeleted);
            }
            if (state.status == HistoryStatus.deletedAll) {
              SnackbarHelper.showSuccess(
                  context, StringConst.kAllHistoryCleared);
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        StringConst.kScanHistory,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          letterSpacing: -0.26,
                        ),
                      ),
                      if (state.histories.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.delete_sweep_outlined),
                          color: AppColors.textTertiary,
                          tooltip: StringConst.kClearAllHistory,
                          onPressed: () => _confirmDeleteAll(context),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                Expanded(
                  child: _buildBody(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HistoryState state) {
    if (state.status == HistoryStatus.loading &&
        state.histories.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }

    if (state.histories.isEmpty) {
      return _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<HistoryBloc>().add(const HistoryLoadRequested()),
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          24, 16, 24, 100 + MediaQuery.of(context).padding.bottom,
        ),
        itemCount: state.histories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _HistoryCard(history: state.histories[index]),
          );
        },
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          StringConst.kClearAllHistory,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        content: Text(
          StringConst.kClearAllHistoryConfirm,
          style: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              StringConst.kCancel,
              style: GoogleFonts.hankenGrotesk(
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctx.read<HistoryBloc>().add(const HistoryDeleteAllRequested());
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.alert,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              StringConst.kDeleteAll,
              style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryTint,
              ),
              child: const Icon(
                Icons.center_focus_weak_rounded,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              StringConst.kNoScansYet,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              StringConst.kStartFirstScanCta,
              textAlign: TextAlign.center,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 14,
                color: AppColors.textTertiary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => context.push(AppRoutes.skinAnalysisRoute),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.28),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  StringConst.kAnalyseSkin,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 15,
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
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History card
// ─────────────────────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final HistoryEntity history;

  const _HistoryCard({required this.history});

  int? get _score {
    try {
      final v = history.aiAnalysis?['overall_score'];
      if (v != null) return (v as num).toInt().clamp(0, 100);
    } catch (_) {}
    return null;
  }

  int? _metric(String key) {
    try {
      final m = history.aiAnalysis?['metrics'] as Map<String, dynamic>?;
      final v = m?[key];
      if (v is int) return v.clamp(0, 100);
      if (v is double) return v.round().clamp(0, 100);
    } catch (_) {}
    return null;
  }

  String _condition(int score) {
    if (score >= 75) return 'Clear';
    if (score >= 60) return 'Mild concerns';
    if (score >= 45) return 'Moderate concerns';
    return 'Significant concerns';
  }

  Color _metricColor(int v) {
    if (v >= 60) return AppColors.good;
    if (v >= 45) return AppColors.warn;
    return AppColors.alert;
  }

  @override
  Widget build(BuildContext context) {
    final score = _score;
    final hydration = _metric('hydration');
    final texture = _metric('texture');
    final clarity = _metric('clarity');
    final hasMetrics = hydration != null && texture != null && clarity != null;

    return GestureDetector(
      onTap: () =>
          context.push(AppRoutes.resultDetailRoute, extra: history),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.hairline),
          boxShadow: const [
            BoxShadow(
              color: Color(0x060E1A15),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo section
            Stack(
              children: [
                _HistoryImage(imageUrl: history.imageUrl),

                // Gradient overlay on image
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x80000000)],
                        stops: [0.45, 1.0],
                      ),
                    ),
                  ),
                ),

                // Date badge top-left
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      DateFormat('MMM d, yyyy').format(history.date),
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Delete button top-right
                Positioned(
                  top: 8,
                  right: 8,
                  child: _DeleteIconButton(historyId: history.id),
                ),

                // Score badge bottom-right on image
                if (score != null)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: _ScoreBadge(score: score),
                  ),
              ],
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Condition + time row
                  Row(
                    children: [
                      if (score != null)
                        _ConditionChip(
                          label: _condition(score),
                          color: _metricColor(score),
                        )
                      else
                        const _ConditionChip(
                          label: 'No score',
                          color: AppColors.faint,
                        ),
                      const Spacer(),
                      Text(
                        DateFormat('h:mm a').format(history.date),
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),

                  // Metric bars
                  if (hasMetrics) ...[
                    const SizedBox(height: 14),
                    _MiniMetricBar(
                      label: StringConst.kHydrationMetric,
                      value: hydration,
                      color: _metricColor(hydration),
                    ),
                    const SizedBox(height: 7),
                    _MiniMetricBar(
                      label: StringConst.kTextureMetric,
                      value: texture,
                      color: _metricColor(texture),
                    ),
                    const SizedBox(height: 7),
                    _MiniMetricBar(
                      label: StringConst.kClarityMetric,
                      value: clarity,
                      color: _metricColor(clarity),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History card sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryImage extends StatelessWidget {
  final String imageUrl;

  const _HistoryImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final isLocal = !imageUrl.startsWith('http');
    const height = 180.0;
    const errorWidget = SizedBox(
      height: height,
      width: double.infinity,
      child: ColoredBox(
        color: AppColors.track,
        child: Icon(Icons.broken_image_outlined,
            size: 40, color: AppColors.textTertiary),
      ),
    );

    if (isLocal) {
      return Image.file(
        File(imageUrl),
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => errorWidget,
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        height: height,
        color: AppColors.track,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (_, __, ___) => errorWidget,
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({required this.score});

  Color get _color {
    if (score >= 60) return AppColors.good;
    if (score >= 45) return AppColors.warn;
    return AppColors.alert;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.55),
        border: Border.all(color: _color, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$score',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            ),
          ),
          Text(
            '/100',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 8,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ConditionChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetricBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MiniMetricBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 68,
          child: Text(
            label,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value / 100.0,
              minHeight: 5,
              backgroundColor: AppColors.hairline,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 26,
          child: Text(
            '$value',
            textAlign: TextAlign.right,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _DeleteIconButton extends StatelessWidget {
  final String historyId;

  const _DeleteIconButton({required this.historyId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmDelete(context),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          StringConst.kDeleteAnalysis,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        content: Text(
          StringConst.kDeleteAnalysisConfirm,
          style: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              StringConst.kCancel,
              style: GoogleFonts.hankenGrotesk(
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<HistoryBloc>()
                  .add(HistoryDeleteRequested(historyId));
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.alert,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              StringConst.kDelete,
              style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
