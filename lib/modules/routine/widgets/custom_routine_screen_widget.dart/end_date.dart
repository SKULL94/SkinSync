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
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(getWidth(context, 16)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              Text('Set End Date',
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(context, 16),
                  )),
              const Spacer(),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeColor: theme.primaryColor,
              ),
            ],
          ),
          if (isEnabled && endDate != null) ...[
            SizedBox(height: getHeight(context, 12)),
            Padding(
              padding: const EdgeInsets.only(left: 56.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('End Date',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(context, 13),
                        color: theme.textTheme.titleMedium?.color
                            ?.withValues(alpha: 0.7),
                      )),
                  SizedBox(height: getHeight(context, 4)),
                  Text(DateFormat('MMM d, y').format(endDate!),
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.w500,
                      )),
                  SizedBox(height: getHeight(context, 8)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonalIcon(
                      onPressed: onDateSelected,
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Edit Date'),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
