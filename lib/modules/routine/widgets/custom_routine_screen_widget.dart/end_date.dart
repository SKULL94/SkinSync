import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class CustomRoutineEndDateSelector extends StatelessWidget {
  final DateTime? endDate;
  final bool isEnabled;
  final Function(bool) onToggle;
  final VoidCallback onDateSelected;

  const CustomRoutineEndDateSelector({
    super.key,
    required this.endDate,
    required this.isEnabled,
    required this.onToggle,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          contentPadding:
              EdgeInsets.symmetric(horizontal: getWidth(context, 4)),
          title: Text(
            'Set End Date',
            style: TextStyle(fontSize: getResponsiveFontSize(context, 16)),
          ),
          value: isEnabled,
          onChanged: onToggle,
        ),
        if (isEnabled && endDate != null)
          ListTile(
            leading: Icon(Icons.calendar_today, size: getWidth(context, 24)),
            title: Text(
              'End Date: ${DateFormat('MMM d, y').format(endDate!)}',
              style: TextStyle(fontSize: getResponsiveFontSize(context, 14)),
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit_calendar, size: getWidth(context, 24)),
              onPressed: onDateSelected,
            ),
          ),
      ],
    );
  }
}
