import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/di/injection_container.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:skin_sync/core/utils/snackbar_helper.dart';
import 'package:skin_sync/features/history/domain/entities/history_entity.dart';
import 'package:skin_sync/features/history/presentation/bloc/history_bloc.dart';
import 'package:skin_sync/features/layout/presentation/bloc/layout_bloc.dart';
import 'package:skin_sync/features/skin_analysis/data/models/ai_analysis_model.dart';
import 'package:skin_sync/features/skin_analysis/presentation/bloc/face_camera_bloc.dart';
import 'package:skin_sync/features/skin_analysis/presentation/bloc/skin_analysis_bloc.dart';
import 'package:skin_sync/features/skin_analysis/presentation/widgets/face_camera_view.dart';

class SkinAnalysisPage extends StatelessWidget {
  const SkinAnalysisPage({super.key});

  int _getSeverityColorValue(String severity) {
    return switch (severity.toLowerCase()) {
      'mild' => 0xFF15B277,
      'moderate' => 0xFFE8A33D,
      'severe' => 0xFFF2664B,
      'needs_dermatologist' => 0xFFF2664B,
      _ => 0xFF6E7C75,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SkinAnalysisBloc, SkinAnalysisState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == SkinAnalysisStatus.failure &&
            state.errorMessage != null) {
          SnackbarHelper.showError(context, state.errorMessage!);
        }
        if (state.status == SkinAnalysisStatus.saved) {
          SnackbarHelper.showSuccess(context, StringConst.kAnalysisSavedSuccess);

          if (state.selectedImage != null && state.aiAnalysis != null) {
            final ai = state.aiAnalysis!;
            final historyEntity = HistoryEntity(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              imageUrl: state.selectedImage!.path,
              results: [
                {
                  'displayLabel': 'Skin Health Score',
                  'confidence': ai.overallScore / 100.0,
                  'riskLevel': ai.severity,
                  'riskColorValue': _getSeverityColorValue(ai.severity),
                },
              ],
              date: DateTime.now(),
              aiAnalysis: ai.toJson(),
            );
            context.read<HistoryBloc>().add(HistoryAddOptimistic(historyEntity));
          }

          context.read<LayoutBloc>().add(const LayoutTabChanged(1));
          context.go(AppRoutes.layoutRoute);
        }
      },
      builder: (context, state) {
        if (state.status == SkinAnalysisStatus.validating ||
            state.status == SkinAnalysisStatus.analyzingWithAI) {
          return _ProcessingView(
            image: state.selectedImage,
            isAIAnalyzing: state.status == SkinAnalysisStatus.analyzingWithAI,
          );
        }

        if (state.selectedImage != null && state.aiAnalysis != null) {
          return _ResultsView(state: state);
        }

        return BlocProvider(
          create: (_) => sl<FaceCameraBloc>(),
          child: FaceCameraView(
            onImageCaptured: (imageFile) {
              context
                  .read<SkinAnalysisBloc>()
                  .add(SkinAnalysisImageSelected(imageFile));
            },
            onBack: () => context.pop(),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROCESSING VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _ProcessingView extends StatefulWidget {
  final File? image;
  final bool isAIAnalyzing;

  const _ProcessingView({this.image, this.isAIAnalyzing = false});

  @override
  State<_ProcessingView> createState() => _ProcessingViewState();
}

class _ProcessingViewState extends State<_ProcessingView>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _progressController;

  List<String> get _steps => widget.isAIAnalyzing
      ? [
          StringConst.kConnectingToAi,
          StringConst.kAnalyzingSkinTexture,
          StringConst.kEvaluatingSkinHealth,
          StringConst.kDetectingConcerns,
          StringConst.kGeneratingInsights,
          StringConst.kPreparingRecommendations,
        ]
      : [
          StringConst.kValidatingImage,
          StringConst.kDetectingSkinRegions,
          StringConst.kInitialAnalysis,
          StringConst.kPreparingForAi,
        ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..addListener(() {
        final newStep = (_progressController.value * _steps.length).floor();
        final bloc = context.read<SkinAnalysisBloc>();
        if (newStep != bloc.state.scanningStep && newStep < _steps.length) {
          bloc.add(SkinAnalysisScanningStepChanged(newStep));
        }
      });

    _progressController.forward();
  }

  @override
  void dispose() {
    _spinController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SkinAnalysisBloc, SkinAnalysisState>(
      buildWhen: (previous, current) =>
          previous.scanningStep != current.scanningStep,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.deepEnd,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Deep emerald gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.deepStart, AppColors.deepEnd],
                  ),
                ),
              ),

              // Subtle grid lines
              CustomPaint(painter: _GridPainter()),

              // Photo tint in background
              if (widget.image != null)
                Opacity(
                  opacity: 0.15,
                  child: Image.file(widget.image!, fit: BoxFit.cover),
                ),

              // Radial glow
              Center(
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accentBright.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSpinner(),
                      const SizedBox(height: 36),
                      Text(
                        widget.isAIAnalyzing
                            ? StringConst.kAiAnalysing
                            : StringConst.kValidating,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.22,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _steps[
                              state.scanningStep.clamp(0, _steps.length - 1)],
                          key: ValueKey(state.scanningStep),
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildProgressBar(),
                      const SizedBox(height: 18),
                      _buildStepDots(state.scanningStep),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpinner() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          AnimatedBuilder(
            animation: _spinController,
            builder: (_, __) => Transform.rotate(
              angle: _spinController.value * 2 * math.pi,
              child: const SizedBox(
                width: 160,
                height: 160,
                child: CustomPaint(
                  painter: _ArcPainter(
                    color: AppColors.accentBright,
                    strokeWidth: 1.5,
                    sweepAngle: math.pi * 0.6,
                  ),
                ),
              ),
            ),
          ),
          // Middle ring (counter-spin)
          AnimatedBuilder(
            animation: _spinController,
            builder: (_, __) => Transform.rotate(
              angle: -_spinController.value * 2 * math.pi * 0.7,
              child: const SizedBox(
                width: 124,
                height: 124,
                child: CustomPaint(
                  painter: _ArcPainter(
                    color: AppColors.primaryLight,
                    strokeWidth: 1.5,
                    sweepAngle: math.pi * 0.4,
                  ),
                ),
              ),
            ),
          ),
          // Inner ring
          AnimatedBuilder(
            animation: _spinController,
            builder: (_, __) => Transform.rotate(
              angle: _spinController.value * 2 * math.pi * 0.5,
              child: const SizedBox(
                width: 90,
                height: 90,
                child: CustomPaint(
                  painter: _ArcPainter(
                    color: AppColors.accentBright,
                    strokeWidth: 1,
                    sweepAngle: math.pi * 0.3,
                  ),
                ),
              ),
            ),
          ),
          // Center dot
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.deepCore,
            ),
            child: Icon(
              Icons.face_outlined,
              size: 24,
              color: AppColors.accentBright.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (_, __) {
        return Container(
          width: 180,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progressController.value,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.accentBright,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepDots(int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _steps.length,
        (i) => Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i <= currentStep
                ? AppColors.accentBright
                : Colors.white.withValues(alpha: 0.12),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESULTS VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _ResultsView extends StatelessWidget {
  final SkinAnalysisState state;

  const _ResultsView({required this.state});

  Color _metricColor(int value) {
    if (value >= 60) return AppColors.good;
    if (value >= 45) return AppColors.warn;
    return AppColors.alert;
  }

  Color _severityColor(String severity) {
    return switch (severity.toLowerCase()) {
      'clear' => AppColors.good,
      'mild' => AppColors.good,
      'moderate' => AppColors.warn,
      'severe' || 'needs_dermatologist' => AppColors.alert,
      _ => AppColors.warn,
    };
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
    final ai = state.aiAnalysis!;

    return Scaffold(
      backgroundColor: AppColors.deepEnd,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Photo background
          if (state.selectedImage != null)
            Opacity(
              opacity: 0.35,
              child: Image.file(state.selectedImage!, fit: BoxFit.cover),
            ),

          // Gradient overlay (transparent top → deepEnd bottom)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.deepEnd],
                stops: [0.0, 0.55],
              ),
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            child: GestureDetector(
              onTap: () => context
                  .read<SkinAnalysisBloc>()
                  .add(const SkinAnalysisReset()),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),

          // Draggable results sheet
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

                        // Score + condition header
                        _ScoreHeader(
                          score: ai.overallScore,
                          condition: _condition(ai.overallScore),
                          conditionColor: _metricColor(ai.overallScore),
                          skinType: ai.skinType,
                          severity: ai.severity,
                          severityColor: _severityColor(ai.severity),
                        ),

                        const SizedBox(height: 20),

                        // Quick metrics row
                        _QuickMetricsRow(ai: ai, metricColor: _metricColor),

                        // AI Insight
                        if (ai.aiInsight != null) ...[
                          const SizedBox(height: 16),
                          _AIInsightCard(insight: ai.aiInsight!),
                        ],

                        const SizedBox(height: 16),

                        // Disclaimer
                        _DisclaimerCard(
                          needsWarning: ai.disclaimerRequired,
                          severity: ai.severity,
                        ),

                        // Detected concerns
                        if (ai.detectedConcerns.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const _SectionLabel(label: StringConst.kDetectedConcerns),
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
                        const _SectionLabel(label: StringConst.kDetailedAnalysis),
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
                          const _SectionLabel(label: StringConst.kRecommendations),
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

                        // Save button
                        _SaveButton(
                          isSaving: state.status == SkinAnalysisStatus.saving,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Results sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ScoreHeader extends StatelessWidget {
  final int score;
  final String condition;
  final Color conditionColor;
  final String skinType;
  final String severity;
  final Color severityColor;

  const _ScoreHeader({
    required this.score,
    required this.condition,
    required this.conditionColor,
    required this.skinType,
    required this.severity,
    required this.severityColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Score ring
        _ScoreRing(score: score, color: conditionColor),

        const SizedBox(width: 20),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "ANALYSIS COMPLETE" chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(999),
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
                DateFormat('MMMM d, yyyy').format(DateTime.now()),
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textTertiary,
                ),
              ),

              const SizedBox(height: 10),

              // Condition chip + skin type chip
              Wrap(
                spacing: 6,
                children: [
                  _TagChip(
                    label: condition,
                    color: conditionColor,
                  ),
                  _TagChip(
                    label: skinType,
                    color: AppColors.primary,
                  ),
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
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
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

class _QuickMetricsRow extends StatelessWidget {
  final AIAnalysisModel ai;
  final Color Function(int) metricColor;

  const _QuickMetricsRow({required this.ai, required this.metricColor});

  @override
  Widget build(BuildContext context) {
    final items = [
      (StringConst.kHydrationMetric, ai.metrics.hydration),
      (StringConst.kTextureMetric, ai.metrics.texture),
      (StringConst.kClarityMetric, ai.metrics.clarity),
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
                border: Border.all(color: AppColors.hairline, width: 1),
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
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
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

class _DisclaimerCard extends StatelessWidget {
  final bool needsWarning;
  final String severity;

  const _DisclaimerCard(
      {required this.needsWarning, required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = needsWarning ? AppColors.alert : AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: color.withValues(alpha: 0.2), width: 1),
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
                fontWeight: FontWeight.w400,
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
        border: Border.all(
            color: AppColors.alert.withValues(alpha: 0.25), width: 1),
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
        border: Border.all(color: AppColors.hairline, width: 1),
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
              fontWeight: FontWeight.w400,
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
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25), width: 1),
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
        border: Border.all(color: AppColors.hairline, width: 1),
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
                fontWeight: FontWeight.w400,
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

class _SaveButton extends StatelessWidget {
  final bool isSaving;

  const _SaveButton({required this.isSaving});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSaving
          ? null
          : () => context
              .read<SkinAnalysisBloc>()
              .add(const SkinAnalysisSaveRequested()),
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: isSaving
              ? null
              : const LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primaryDark],
                ),
          color: isSaving ? AppColors.hairline : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSaving
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.30),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
        ),
        child: Center(
          child: isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : Text(
                  StringConst.kSaveAnalysis,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painters
// ─────────────────────────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double sweepAngle;

  const _ArcPainter({
    required this.color,
    required this.strokeWidth,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -math.pi / 2,
      sweepAngle,
      false,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.color != color || old.sweepAngle != sweepAngle;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;

    const step = 30.0;
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter _) => false;
}
