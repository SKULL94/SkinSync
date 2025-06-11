import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class RoutineScreenEmptyState extends StatelessWidget {
  const RoutineScreenEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/images/Main Scene.json',
            width: MediaQuery.of(context).size.width * 0.7,
          ),
          const SizedBox(height: 24),
          Text(
            "No Routines Found",
            style: TextStyle(
              fontSize: getResponsiveFontSize(context, 20),
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the + button to create your first routine!",
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
