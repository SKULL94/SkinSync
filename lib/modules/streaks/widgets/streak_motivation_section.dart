import 'package:flutter/material.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class MotivationSection extends StatelessWidget {
  const MotivationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: getHeight(context, 20),
        horizontal: getWidth(context, 20),
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF2E8EB),
        borderRadius: BorderRadius.circular(getWidth(context, 16)),
      ),
      child: Column(
        children: [
          Text(
            'Keep the streak alive!',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: const Color(0xff964F66),
            ),
          ),
          SizedBox(height: getHeight(context, 12)),
          Text(
            'Complete your routines daily to maintain your streak',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: getResponsiveFontSize(context, 14),
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
