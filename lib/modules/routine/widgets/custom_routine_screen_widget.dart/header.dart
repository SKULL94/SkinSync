import 'package:flutter/material.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class CustomRoutineHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;

  const CustomRoutineHeader({
    super.key,
    this.title = 'New Skin Routine',
    this.subtitle = 'Create your personalized skincare regimen',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: getResponsiveFontSize(context, 14),
            color: theme.textTheme.titleMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
