import 'package:flutter/material.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class RoutineScreenLoadingState extends StatelessWidget {
  const RoutineScreenLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        SizedBox(height: getHeight(context, 16)),
        Text('Loading your routines...',
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: getResponsiveFontSize(context, 14))),
      ],
    );
  }
}
