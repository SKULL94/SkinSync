import 'package:flutter/material.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class CustomRoutineTimeSelector extends StatelessWidget {
  const CustomRoutineTimeSelector(
      {super.key, required this.onSelectTime, required this.selectedTime});

  final VoidCallback onSelectTime;
  final TimeOfDay selectedTime;

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
            child: Icon(Icons.access_time_rounded, color: theme.primaryColor),
          ),
          SizedBox(width: getWidth(context, 16)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Routine Time',
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(context, 13),
                    color: theme.textTheme.titleMedium?.color
                        ?.withValues(alpha: 0.7),
                  )),
              SizedBox(height: getHeight(context, 4)),
              Text(selectedTime.format(context),
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
          const Spacer(),
          FilledButton.tonalIcon(
            onPressed: onSelectTime,
            icon: Icon(Icons.edit, size: 18),
            label: Text('Change'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }
}
