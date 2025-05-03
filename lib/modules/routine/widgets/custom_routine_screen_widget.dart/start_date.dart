import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class CustomRoutineStartDateSelector extends StatelessWidget {
  final DateTime? startDate;
  final bool isEnabled;
  final Function(bool) onToggle;
  final Function() onDateChanged;

  const CustomRoutineStartDateSelector({
    super.key,
    required this.startDate,
    required this.isEnabled,
    required this.onToggle,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          contentPadding:
              EdgeInsets.symmetric(horizontal: getWidth(context, 4)),
          title: Text(
            'Set Start Date',
            style: TextStyle(fontSize: getResponsiveFontSize(context, 16)),
          ),
          value: isEnabled,
          onChanged: onToggle,
        ),
        if (isEnabled && startDate != null)
          ListTile(
            leading: Icon(Icons.calendar_today, size: getWidth(context, 24)),
            title: Text(
              'Start Date: ${DateFormat('MMM d, y').format(startDate!)}',
              style: TextStyle(fontSize: getResponsiveFontSize(context, 14)),
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit, size: getWidth(context, 24)),
              onPressed: onDateChanged,
            ),
          ),
      ],
    );
  }
}
