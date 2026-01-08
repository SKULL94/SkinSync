import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:skin_sync/core/utils/mediaquery.dart';
import 'package:skin_sync/features/routine/presentation/bloc/routine_bloc.dart';
import 'package:skin_sync/features/streaks/presentation/bloc/streaks_bloc.dart';

class RoutineHeader extends StatelessWidget {
  final String userName;

  const RoutineHeader({
    super.key,
    required this.userName,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(getWidth(context, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()},',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer
                    .withValues(alpha: 0.8),
              ),
            ),
            Text(
              userName,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            SizedBox(height: getHeight(context, 4)),
            Text(
              today,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer
                    .withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: getHeight(context, 20)),
            _buildStatsRow(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildProgressCard(context, theme),
        ),
        SizedBox(width: getWidth(context, 12)),
        Expanded(
          child: _buildStreakCard(context, theme),
        ),
      ],
    );
  }

  Widget _buildProgressCard(BuildContext context, ThemeData theme) {
    return BlocBuilder<RoutineBloc, RoutineState>(
      builder: (context, state) {
        final completed = state.completedCount;
        final total = state.filteredRoutines.length;
        final progress = total > 0 ? completed / total : 0.0;

        return Container(
          padding: EdgeInsets.all(getWidth(context, 16)),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: getWidth(context, 20),
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: getWidth(context, 8)),
                  Text(
                    "Today's Progress",
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SizedBox(height: getHeight(context, 12)),
              Text(
                '$completed / $total',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: getHeight(context, 8)),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreakCard(BuildContext context, ThemeData theme) {
    return BlocBuilder<StreaksBloc, StreaksState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () => context.push(AppRoutes.skinAnalysisRoute),
          child: Container(
            padding: EdgeInsets.all(getWidth(context, 16)),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: getWidth(context, 20),
                      color: Colors.orange,
                    ),
                    SizedBox(width: getWidth(context, 8)),
                    Text(
                      'Current Streak',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: getHeight(context, 12)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${state.currentStreak}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(width: getWidth(context, 4)),
                    Text(
                      state.currentStreak == 1 ? 'day' : 'days',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: getHeight(context, 8)),
                Text(
                  _getStreakMessage(state.currentStreak),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStreakMessage(int streak) {
    if (streak == 0) return 'Start today!';
    if (streak < 7) return 'Keep going!';
    if (streak < 30) return 'Amazing!';
    return 'Champion!';
  }
}
