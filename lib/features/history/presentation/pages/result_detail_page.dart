import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/utils/snackbar_helper.dart';
import 'package:skin_sync/features/history/domain/entities/history_entity.dart';
import 'package:skin_sync/features/history/presentation/bloc/history_bloc.dart';
import 'package:skin_sync/features/skin_analysis/data/models/ai_analysis_model.dart';

class ResultDetailPage extends StatelessWidget {
  final HistoryEntity history;

  const ResultDetailPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final ai = _parseAI();
    return ai == null
        ? _NoDataView(history: history)
        : _DetailView(history: history, ai: ai);
  }

  AIAnalysisModel? _parseAI() {
    try {
      if (history.aiAnalysis == null) return null;
      return AIAnalysisModel.fromJson(history.aiAnalysis!);
    } catch (_) {
      return null;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// No-data fallback
// ─────────────────────────────────────────────────────────────────────────────
class _NoDataView extends StatelessWidget {
  final HistoryEntity history;

  const _NoDataView({required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.ink,
          onPressed: () => context.pop(),
        ),
        title: Text(
          StringConst.kScanResults,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.track,
                ),
                child: const Icon(
                  Icons.bar_chart_outlined,
                  size: 36,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                StringConst.kAnalysisNotAvailable,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textTertiary,
                  height: 1.55,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full detail view
// ─────────────────────────────────────────────────────────────────────────────
class _DetailView extends StatelessWidget {
  final HistoryEntity history;
  final AIAnalysisModel ai;

  const _DetailView({required this.history, required this.ai});

  Color _metricColor(int v) {
    if (v >= 60) return AppColors.good;
    if (v >= 45) return AppColors.warn;
    return AppColors.alert;
  }

  String _condition(int score) {
    if (score >= 75) return 'Clear';
    if (score >= 60) return 'Mild concerns';
    if (score >= 45) return 'Moderate concerns';
    return 'Significant concerns';
  }

  String _hydrationDesc(int v) {
    if (v >= 70) return StringConst.kHydrationExcellent;
    if (v >= 50) return StringConst.kHydrationModerate;
    return StringConst.kHydrationLow;
  }

  String _textureDesc(int v) {
    if (v >= 70) return StringConst.kTextureExcellent;
    if (v >= 50) return StringConst.kTextureModerate;
    return StringConst.kTextureLow;
  }

  String _clarityDesc(int v) {
    if (v >= 70) return StringConst.kClarityExcellent;
    if (v >= 50) return StringConst.kClarityModerate;
    return StringConst.kClarityLow;
  }

  String _poreDesc(int v) {
    if (v <= 30) return StringConst.kPoreMinimal;
    if (v <= 60) return StringConst.kPoreNormal;
    return StringConst.kPoreEnlarged;
  }

  @override
  Widget build(BuildContext context) {
    final conditionColor = _metricColor(ai.overallScore);

    return BlocListener<HistoryBloc, HistoryState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == HistoryStatus.deleted) {
          SnackbarHelper.showSuccess(context, StringConst.kAnalysisDeleted);
          context.pop();
        }
        if (state.status == HistoryStatus.failure &&
            state.errorMessage != null) {
          SnackbarHelper.showError(context, state.errorMessage!);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.deepEnd,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Photo background
            _buildPhotoBackground(),

            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.deepEnd],
                  stops: [0.0, 0.52],
                ),
              ),
            ),

            // Back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20,
              child: _BackButton(),
            ),

            // Results sheet
            DraggableScrollableSheet(
              initialChildSize: 0.58,
              minChildSize: 0.45,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag handle
                          const SizedBox(height: 12),
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.hairline,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Score header
                          _ScoreHeader(
                            score: ai.overallScore,
                            condition: _condition(ai.overallScore),
                            conditionColor: conditionColor,
                            skinType: ai.skinType,
                            date: history.date,
                          ),

                          const SizedBox(height: 20),

                          // Quick metrics
                          _QuickMetrics(
                            hydration: ai.metrics.hydration,
                            texture: ai.metrics.texture,
                            clarity: ai.metrics.clarity,
                            metricColor: _metricColor,
                          ),

                          // AI Insight
                          if (ai.aiInsight != null) ...[
                            const SizedBox(height: 16),
                            _AIInsightCard(insight: ai.aiInsight!),
                          ],

                          const SizedBox(height: 16),

                          // Disclaimer
                          _DisclaimerBanner(
                              needsWarning: ai.disclaimerRequired),

                          // Detected concerns
                          if (ai.detectedConcerns.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            const _SectionLabel(
                                label: StringConst.kDetectedConcerns),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ai.detectedConcerns
                                  .map((c) => _ConcernChip(label: c))
                                  .toList(),
                            ),
                          ],

                          // Detailed analysis
                          const SizedBox(height: 24),
                          const _SectionLabel(
                              label: StringConst.kDetailedAnalysis),
                          const SizedBox(height: 12),
                          _MetricCard(
                            title: StringConst.kHydrationMetric,
                            value: ai.metrics.hydration,
                            description: _hydrationDesc(ai.metrics.hydration),
                            color: _metricColor(ai.metrics.hydration),
                          ),
                          const SizedBox(height: 10),
                          _MetricCard(
                            title: StringConst.kTextureMetric,
                            value: ai.metrics.texture,
                            description: _textureDesc(ai.metrics.texture),
                            color: _metricColor(ai.metrics.texture),
                          ),
                          const SizedBox(height: 10),
                          _MetricCard(
                            title: StringConst.kClarityMetric,
                            value: ai.metrics.clarity,
                            description: _clarityDesc(ai.metrics.clarity),
                            color: _metricColor(ai.metrics.clarity),
                          ),
                          const SizedBox(height: 10),
                          _MetricCard(
                            title: StringConst.kPoreVisibility,
                            value: ai.metrics.poreVisibility,
                            description: _poreDesc(ai.metrics.poreVisibility),
                            color: _metricColor(ai.metrics.poreVisibility),
                          ),

                          // Recommendations
                          if (ai.recommendations.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            const _SectionLabel(
                                label: StringConst.kRecommendations),
                            const SizedBox(height: 12),
                            ...ai.recommendations.asMap().entries.map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _RecommendationCard(
                                      index: e.key + 1,
                                      text: e.value,
                                    ),
                                  ),
                                ),
                          ],

                          // Ingredients
                          if (ai.ingredientsToLookFor.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            const _SectionLabel(
                                label: StringConst.kIngredientsToLookFor),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ai.ingredientsToLookFor
                                  .map((i) => _IngredientChip(label: i))
                                  .toList(),
                            ),
                          ],

                          const SizedBox(height: 28),

                          // Delete scan button
                          _DeleteButton(historyId: history.id),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoBackground() {
    final isLocal = !history.imageUrl.startsWith('http');
    if (isLocal) {
      return Opacity(
        opacity: 0.35,
        child: Image.file(
          File(history.imageUrl),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const ColoredBox(color: AppColors.deepEnd),
        ),
      );
    }
    return Opacity(
      opacity: 0.35,
      child: CachedNetworkImage(
        imageUrl: history.imageUrl,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) =>
            const ColoredBox(color: AppColors.deepEnd),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Icon(
          Icons.arrow_back_ios_new,
          size: 16,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  final int score;
  final String condition;
  final Color conditionColor;
  final String skinType;
  final DateTime date;

  const _ScoreHeader({
    required this.score,
    required this.condition,
    required this.conditionColor,
    required this.skinType,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ScoreRing(score: score, color: conditionColor),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                child: Text(
                  StringConst.kAnalysisComplete,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                StringConst.kYourSkinHealth,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: -0.2,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMMM d, yyyy').format(date),
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: [
                  _TagChip(label: condition, color: conditionColor),
                  _TagChip(label: skinType, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreRing extends StatelessWidget {
  final int score;
  final Color color;

  const _ScoreRing({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox(
            width: 96,
            height: 96,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 8,
              backgroundColor: AppColors.hairline,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.hairline),
            ),
          ),
          SizedBox(
            width: 96,
            height: 96,
            child: CircularProgressIndicator(
              value: score / 100.0,
              strokeWidth: 8,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  height: 1,
                ),
              ),
              Text(
                '/100',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.hankenGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _QuickMetrics extends StatelessWidget {
  final int hydration;
  final int texture;
  final int clarity;
  final Color Function(int) metricColor;

  const _QuickMetrics({
    required this.hydration,
    required this.texture,
    required this.clarity,
    required this.metricColor,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (StringConst.kHydrationMetric, hydration),
      (StringConst.kTextureMetric, texture),
      (StringConst.kClarityMetric, clarity),
    ];

    return Row(
      children: items.asMap().entries.map((e) {
        final idx = e.key;
        final (label, value) = e.value;
        final color = metricColor(value);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: idx == 0 ? 0 : 8),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$value',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: value / 100.0,
                      minHeight: 4,
                      backgroundColor: AppColors.hairline,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AIInsightCard extends StatelessWidget {
  final String insight;

  const _AIInsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StringConst.kAiInsight,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.ink,
                    height: 1.55,
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

class _DisclaimerBanner extends StatelessWidget {
  final bool needsWarning;

  const _DisclaimerBanner({required this.needsWarning});

  @override
  Widget build(BuildContext context) {
    final color = needsWarning ? AppColors.alert : AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            needsWarning ? Icons.warning_amber_rounded : Icons.info_outline,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              needsWarning
                  ? StringConst.kConsultDermatologist
                  : StringConst.kAiDisclaimer,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        letterSpacing: -0.17,
      ),
    );
  }
}

class _ConcernChip extends StatelessWidget {
  final String label;

  const _ConcernChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.alertTint,
        borderRadius: BorderRadius.circular(999),
        border:
            Border.all(color: AppColors.alert.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.hankenGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.alertTintInk,
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final int value;
  final String description;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$value',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100.0,
              minHeight: 5,
              backgroundColor: AppColors.hairline,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 13,
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientChip extends StatelessWidget {
  final String label;

  const _IngredientChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(999),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.hankenGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryTintInk,
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final int index;
  final String text;

  const _RecommendationCard({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: AppColors.primaryTint,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 13,
                color: AppColors.ink,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final String historyId;

  const _DeleteButton({required this.historyId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        final isDeleting = state.status == HistoryStatus.loading;
        return GestureDetector(
          onTap: isDeleting ? null : () => _confirmDelete(context),
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.alertTint,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.alert.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.alert,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.delete_outline,
                            size: 18, color: AppColors.alertTintInk),
                        const SizedBox(width: 8),
                        Text(
                          StringConst.kDeleteScan,
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.alertTintInk,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
                borderRadius: BorderRadius.circular(10),
              ),
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
