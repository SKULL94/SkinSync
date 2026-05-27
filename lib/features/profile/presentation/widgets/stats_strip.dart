import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/constants/text_styles.dart';
import 'package:skin_sync/features/history/presentation/bloc/history_bloc.dart';

class StatsStrip extends StatelessWidget {
  const StatsStrip({super.key});

  int _calculateScore(dynamic results) {
    try {
      if (results != null && results is List && results.isNotEmpty) {
        final topConfidence = (results.first['confidence'] as num?)?.toDouble() ?? 0.5;
        return (50 + (topConfidence * 50)).toInt().clamp(0, 100);
      }
    } catch (_) {}
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      buildWhen: (prev, curr) => prev.histories != curr.histories,
      builder: (context, state) {
        final histories = state.histories;
        final totalScans = histories.length;

        int bestScore = 0;
        int firstScore = 0;
        int latestScore = 0;

        if (histories.isNotEmpty) {
          for (final h in histories) {
            final score = _calculateScore(h.results);
            if (score > bestScore) bestScore = score;
          }
          firstScore = _calculateScore(histories.last.results);
          latestScore = _calculateScore(histories.first.results);
        }

        final improvement = totalScans > 1 ? latestScore - firstScore : 0;
        final improvementText = improvement >= 0 ? '+$improvement' : '$improvement';

        return Container(
          color: const Color(0xFF3D2E22),
          child: Row(
            children: [
              _StatCell(value: '$totalScans', label: StringConst.kScans),
              const _StatDivider(),
              _StatCell(
                value: bestScore > 0 ? '$bestScore' : '-',
                label: StringConst.kBestScore,
              ),
              const _StatDivider(),
              _StatCell(
                value: totalScans > 1 ? improvementText : '-',
                label: StringConst.kImprovement,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;

  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(
                fontSize: 22,
                color: const Color(0xFFF2EDE6),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.overline.copyWith(
                fontSize: 9,
                letterSpacing: 1,
                color: const Color(0xFFF2EDE6).withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.05),
    );
  }
}
