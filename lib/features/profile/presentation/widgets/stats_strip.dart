import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/features/history/domain/entities/history_entity.dart';
import 'package:skin_sync/features/history/presentation/bloc/history_bloc.dart';

class StatsStrip extends StatelessWidget {
  const StatsStrip({super.key});

  int _overallScore(HistoryEntity h) {
    try {
      final v = h.aiAnalysis?['overall_score'];
      if (v != null) return (v as num).toInt().clamp(0, 100);
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
            final s = _overallScore(h);
            if (s > bestScore) bestScore = s;
          }
          firstScore = _overallScore(histories.last);
          latestScore = _overallScore(histories.first);
        }

        final improvement = totalScans > 1 ? latestScore - firstScore : 0;
        final improvementText =
            improvement >= 0 ? '+$improvement' : '$improvement';
        final improvementColor = improvement >= 0
            ? AppColors.accentBright
            : AppColors.alert.withValues(alpha: 0.85);

        return Container(
          color: AppColors.deepCore,
          child: Row(
            children: [
              _StatCell(
                value: '$totalScans',
                label: StringConst.kScans,
                valueColor: Colors.white,
              ),
              _StatDivider(),
              _StatCell(
                value: bestScore > 0 ? '$bestScore' : '—',
                label: StringConst.kBestScore,
                valueColor: AppColors.accentBright,
              ),
              _StatDivider(),
              _StatCell(
                value: totalScans > 1 ? improvementText : '—',
                label: StringConst.kImprovement,
                valueColor: totalScans > 1 ? improvementColor : Colors.white,
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
  final Color valueColor;

  const _StatCell({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: valueColor,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.1,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha: 0.07),
    );
  }
}
