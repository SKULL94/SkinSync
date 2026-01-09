import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/core/utils/mediaquery.dart';

class RoutineDateNavigation extends StatelessWidget {
  final DateTime selectedDate;
  final DateFormat dateFormat;
  final Function(DateTime) onDateChanged;

  const RoutineDateNavigation({
    super.key,
    required this.selectedDate,
    required this.dateFormat,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(context, 16),
        vertical: getHeight(context, 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              onDateChanged(
                selectedDate.subtract(const Duration(days: 1)),
              );
            },
            icon: const Icon(Icons.chevron_left),
          ),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(context, 16),
                vertical: getHeight(context, 8),
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isToday(selectedDate)
                    ? 'Today'
                    : dateFormat.format(selectedDate),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              onDateChanged(
                selectedDate.add(const Duration(days: 1)),
              );
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateChanged(picked);
    }
  }
}
