import 'package:flutter/material.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class CustomRoutineHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const CustomRoutineHeader({
    super.key,
    this.title = 'New Skin Routine',
    this.subtitle = 'Create your personalized skincare regimen',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: getResponsiveFontSize(context, 14),
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
