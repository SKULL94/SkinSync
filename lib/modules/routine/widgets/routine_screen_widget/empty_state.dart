import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class RoutineScreenEmptyState extends StatelessWidget {
  const RoutineScreenEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Lottie.asset(
            'assets/images/Main Scene.json',
            width: getHeight(context, 250),
            height: getHeight(context, 250),
            repeat: true,
            frameRate: const FrameRate(60),
            addRepaintBoundary: true,
          ),
          SizedBox(height: getHeight(context, 15)),
          Text("No Routines Found",
              style: TextStyle(
                  fontSize: getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const Text("Tap the + button to create your first routine!"),
        ],
      ),
    );
  }
}
