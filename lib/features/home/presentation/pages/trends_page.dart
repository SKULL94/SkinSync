import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/features/history/domain/entities/history_entity.dart';
import 'package:skin_sync/features/history/presentation/bloc/history_bloc.dart';

class TrendsPage extends StatelessWidget {
  const TrendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: BlocBuilder<HistoryBloc, HistoryState>(
                builder: (context, state) {
                  if (state.histories.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _TrendsContent(histories: state.histories);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SKIN HEALTH',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Progress Trends',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.show_chart,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Data Yet',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete at least 2 skin scans to see\nyour progress trends over time.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textTertiary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendsContent extends StatelessWidget {
  final List<HistoryEntity> histories;

  const _TrendsContent({required this.histories});

  List<_DataPoint> _getDataPoints() {
    final points = <_DataPoint>[];
    for (final history in histories.reversed) {
      int score = 50;
      if (history.aiAnalysis != null) {
        score = (history.aiAnalysis!['overall_score'] as num?)?.toInt() ?? 50;
      } else if (history.results.isNotEmpty) {
        final confidence =
            (history.results.first['confidence'] as num?)?.toDouble() ?? 0.5;
        score = (50 + (confidence * 50)).toInt().clamp(0, 100);
      }
      points.add(_DataPoint(date: history.date, score: score));
    }
    return points;
  }

  Map<String, int> _getMetricAverages() {
    if (histories.isEmpty) return {};

    int totalHydration = 0, totalTexture = 0, totalClarity = 0;
    int count = 0;

    for (final history in histories) {
      if (history.aiAnalysis != null) {
        final metrics = history.aiAnalysis!['metrics'] as Map<String, dynamic>?;
        if (metrics != null) {
          totalHydration += (metrics['hydration'] as num?)?.toInt() ?? 50;
          totalTexture += (metrics['texture'] as num?)?.toInt() ?? 50;
          totalClarity += (metrics['clarity'] as num?)?.toInt() ?? 50;
          count++;
        }
      }
    }

    if (count == 0) return {};

    return {
      'Hydration': totalHydration ~/ count,
      'Texture': totalTexture ~/ count,
      'Clarity': totalClarity ~/ count,
    };
  }

  int _calculateImprovement(List<_DataPoint> points) {
    if (points.length < 2) return 0;
    return points.last.score - points.first.score;
  }

  @override
  Widget build(BuildContext context) {
    final dataPoints = _getDataPoints();
    final metrics = _getMetricAverages();
    final improvement = _calculateImprovement(dataPoints);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Total Scans',
                  value: '${histories.length}',
                  icon: Icons.document_scanner_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Improvement',
                  value: improvement >= 0 ? '+$improvement' : '$improvement',
                  icon: improvement >= 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color: improvement >= 0 ? AppColors.sage : AppColors.rose,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Best Score',
                  value: dataPoints.isEmpty
                      ? '-'
                      : '${dataPoints.map((p) => p.score).reduce(math.max)}',
                  icon: Icons.emoji_events_outlined,
                  color: AppColors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Average',
                  value: dataPoints.isEmpty
                      ? '-'
                      : '${(dataPoints.map((p) => p.score).reduce((a, b) => a + b) / dataPoints.length).round()}',
                  icon: Icons.analytics_outlined,
                  color: AppColors.rose,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Score Chart
          Text(
            'Score History',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: dataPoints.length < 2
                ? Center(
                    child: Text(
                      'Need at least 2 scans for chart',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  )
                : _ScoreChart(dataPoints: dataPoints),
          ),

          const SizedBox(height: 24),

          // Metric Averages
          if (metrics.isNotEmpty) ...[
            Text(
              'Average Metrics',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...metrics.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MetricBar(
                    label: entry.key,
                    value: entry.value,
                    color: _getMetricColor(entry.key),
                  ),
                )),
          ],

          const SizedBox(height: 24),

          // Recent Scans
          Text(
            'Recent Scans',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...histories.take(5).map((history) {
            int score = 50;
            if (history.aiAnalysis != null) {
              score =
                  (history.aiAnalysis!['overall_score'] as num?)?.toInt() ?? 50;
            }
            return _RecentScanCard(
              date: history.date,
              score: score,
              imageUrl: history.imageUrl,
            );
          }),
        ],
      ),
    );
  }

  Color _getMetricColor(String metric) {
    switch (metric) {
      case 'Hydration':
        return AppColors.sage;
      case 'Texture':
        return AppColors.primary;
      case 'Clarity':
        return AppColors.rose;
      default:
        return AppColors.amber;
    }
  }
}

class _DataPoint {
  final DateTime date;
  final int score;

  const _DataPoint({required this.date, required this.score});
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreChart extends StatelessWidget {
  final List<_DataPoint> dataPoints;

  const _ScoreChart({required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _ChartPainter(dataPoints: dataPoints),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<_DataPoint> dataPoints;

  _ChartPainter({required this.dataPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.length < 2) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.3),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final gridPaint = Paint()
      ..color = AppColors.cardBorder
      ..strokeWidth = 1;

    final textStyle = TextStyle(
      color: AppColors.textTertiary,
      fontSize: 10,
    );

    // Draw grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(30, y), Offset(size.width, y), gridPaint);

      final score = 100 - (i * 25);
      final textSpan = TextSpan(text: '$score', style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(0, y - 6));
    }

    // Calculate points
    final points = <Offset>[];
    final padding = 30.0;
    final chartWidth = size.width - padding;

    for (int i = 0; i < dataPoints.length; i++) {
      final x = padding + (i / (dataPoints.length - 1)) * chartWidth;
      final y = size.height * (1 - dataPoints[i].score / 100);
      points.add(Offset(x, y));
    }

    // Draw fill
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, paint);

    // Draw dots
    final dotPaint = Paint()..color = AppColors.primary;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final point in points) {
      canvas.drawCircle(point, 5, dotPaint);
      canvas.drawCircle(point, 5, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MetricBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MetricBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$value%',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
              value: value / 100,
              minHeight: 6,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentScanCard extends StatelessWidget {
  final DateTime date;
  final int score;
  final String imageUrl;

  const _RecentScanCard({
    required this.date,
    required this.score,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 50,
              height: 50,
              color: AppColors.cardBorder,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image,
                        color: AppColors.textTertiary,
                      ),
                    )
                  : Icon(Icons.image, color: AppColors.textTertiary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM d, yyyy').format(date),
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('h:mm a').format(date),
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getScoreColor(score).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$score',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: _getScoreColor(score),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 70) return AppColors.sage;
    if (score >= 50) return AppColors.amber;
    return AppColors.rose;
  }
}
