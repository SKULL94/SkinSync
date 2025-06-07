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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(Icons.check_circle_outline_rounded,
            size: getWidth(context, 24)),
        label: Text('Save Routine',
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: getResponsiveFontSize(context, 16))),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: getHeight(context, 16)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(getWidth(context, 12)),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
