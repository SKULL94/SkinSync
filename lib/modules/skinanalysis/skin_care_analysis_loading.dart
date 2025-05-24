import 'package:flutter/material.dart';

class SkinAnalysisLoadingScreen extends StatelessWidget {
  const SkinAnalysisLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(strokeWidth: 2),
            const SizedBox(height: 20),
            Text(
              'Analyzing your skin...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
