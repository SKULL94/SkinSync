import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skin_sync/core/utils/snackbar_helper.dart';
import 'package:skin_sync/features/streaks/domain/entities/streak_entity.dart';
import 'package:skin_sync/features/streaks/presentation/bloc/streaks_bloc.dart';
import 'package:skin_sync/core/utils/mediaquery.dart';

class StreaksPage extends StatelessWidget {
  const StreaksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Streaks',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: getResponsiveFontSize(context, 18),
          ),
        ),
      ),
      body: BlocConsumer<StreaksBloc, StreaksState>(
        listenWhen: (previous, current) =>
            previous.status != current.status,
        listener: (context, state) {
          if (state.status == StreaksStatus.failure &&
              state.errorMessage != null) {
            SnackbarHelper.showError(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          if (state.status == StreaksStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(getWidth(context, 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStreakHeader(context, state, theme),
                SizedBox(height: getHeight(context, 24)),
                _buildStreakTypeSelector(context, state, theme),
                SizedBox(height: getHeight(context, 24)),
                _buildStreakChart(context, state, theme),
                SizedBox(height: getHeight(context, 24)),
                _buildMotivation(context, state, theme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreakHeader(
    BuildContext context,
    StreaksState state,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(getWidth(context, 24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.local_fire_department,
            size: getWidth(context, 60),
            color: Colors.orange,
          ),
          SizedBox(height: getHeight(context, 16)),
          Text(
            '${state.currentStreak}',
            style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          Text(
            'Day Streak',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakTypeSelector(
    BuildContext context,
    StreaksState state,
    ThemeData theme,
  ) {
    return SegmentedButton<StreakType>(
      segments: const [
        ButtonSegment(
          value: StreakType.daily,
          label: Text('Daily'),
        ),
        ButtonSegment(
          value: StreakType.weekly,
          label: Text('Weekly'),
        ),
        ButtonSegment(
          value: StreakType.monthly,
          label: Text('Monthly'),
        ),
      ],
      selected: {state.streakType},
      onSelectionChanged: (Set<StreakType> newSelection) {
        context.read<StreaksBloc>().add(
              StreaksTypeChanged(newSelection.first),
            );
      },
    );
  }

  Widget _buildStreakChart(
    BuildContext context,
    StreaksState state,
    ThemeData theme,
  ) {
    final bloc = context.read<StreaksBloc>();
    final spots = bloc.getDailyChartData(state);

    return Container(
      height: getHeight(context, 200),
      padding: EdgeInsets.all(getWidth(context, 16)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivation(
    BuildContext context,
    StreaksState state,
    ThemeData theme,
  ) {
    String message;
    if (state.currentStreak == 0) {
      message = 'Start your streak today! Complete a routine to begin.';
    } else if (state.currentStreak < 7) {
      message = 'Great start! Keep going to build your habit.';
    } else if (state.currentStreak < 30) {
      message = 'Amazing progress! You\'re building a strong habit.';
    } else {
      message = 'Incredible! You\'re a skincare champion!';
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(getWidth(context, 16)),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: getWidth(context, 12)),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
