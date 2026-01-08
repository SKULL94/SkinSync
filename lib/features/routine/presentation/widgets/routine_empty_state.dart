import 'package:flutter/material.dart';
import 'package:skin_sync/core/utils/mediaquery.dart';

class RoutineEmptyState extends StatelessWidget {
  const RoutineEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note_outlined,
            size: getWidth(context, 80),
            color: theme.colorScheme.outline,
          ),
          SizedBox(height: getHeight(context, 16)),
          Text(
            'No routines for this day',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: getHeight(context, 8)),
          Text(
            'Tap + to add a new routine',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
