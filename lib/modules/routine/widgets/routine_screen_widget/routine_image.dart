import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skin_sync/model/custom_routine.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class RoutineScreenRoutineImage extends StatelessWidget {
  const RoutineScreenRoutineImage({super.key, required this.routine});
  final CustomRoutine routine;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: routine.imagePath,
        width: double.infinity,
        height: getHeight(context, 150),
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: Colors.grey[100],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (_, __, ___) => Container(
          color: Colors.grey[100],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.grey),
              Text('Failed to load image',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: getResponsiveFontSize(context, 14))),
            ],
          ),
        ),
      ),
    );
  }
}
