import 'package:flutter/material.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class RoutineScreenTimeSection extends StatelessWidget {
  const RoutineScreenTimeSection(
      {super.key, required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: getHeight(context, 8)),
      child: Row(
        children: [
          Icon(icon, size: getHeight(context, 20), color: Colors.amber[700]),
          SizedBox(width: getWidth(context, 8)),
          Text(title,
              style: TextStyle(
                  fontSize: getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
