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
    return ListTile(
      leading: Icon(Icons.calendar_today, size: getWidth(context, 24)),
      title: Text(
        'Start Date: ${DateFormat('MMM d, y').format(startDate)}',
        style: TextStyle(fontSize: getResponsiveFontSize(context, 14)),
      ),
      trailing: IconButton(
        icon: Icon(Icons.edit_calendar, size: getWidth(context, 24)),
        onPressed: onDateSelected,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: getWidth(context, 4)),
    );
  }
}
