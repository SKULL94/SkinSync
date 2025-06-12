import 'package:flutter/material.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class CustomRoutineSaveButton extends StatelessWidget {
  const CustomRoutineSaveButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(top: getHeight(context, 20)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(Icons.check_circle_outline_rounded,
            size: getWidth(context, 24)),
        label: Text('Save Routine',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: getResponsiveFontSize(context, 17))),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
              horizontal: getWidth(context, 100),
              vertical: getHeight(context, 18)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: theme.primaryColor,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
