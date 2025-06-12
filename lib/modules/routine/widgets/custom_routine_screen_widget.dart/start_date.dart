import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class CustomRoutineStartDateSelector extends StatelessWidget {
  final DateTime startDate;
  final VoidCallback onDateSelected;

  const CustomRoutineStartDateSelector({
    super.key,
    required this.startDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(getWidth(context, 16)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.calendar_today, color: theme.primaryColor),
          ),
          SizedBox(width: getWidth(context, 16)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Start Date',
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(context, 13),
                    color: theme.textTheme.titleMedium?.color
                        ?.withValues(alpha: 0.7),
                  )),
              SizedBox(height: getHeight(context, 4)),
              Text(DateFormat('MMM d, y').format(startDate),
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
          const Spacer(),
          FilledButton.tonalIcon(
            onPressed: onDateSelected,
            icon: Icon(Icons.edit, size: 18),
            label: Text('Edit'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }
}
