import 'package:flutter/material.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class CustomRoutineFormField extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController descController;
  final bool isTablet;

  const CustomRoutineFormField({
    super.key,
    required this.controller,
    required this.descController,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: getHeight(context, 16),
              horizontal: getWidth(context, isTablet ? 20 : 16),
            ),
            labelText: 'Routine Name',
            hintText: 'e.g., Morning Glow Routine',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.primaryColor, width: 2.0),
            ),
          ),
        ),
        SizedBox(height: getHeight(context, 20)),
        TextFormField(
          controller: descController,
          maxLines: 3,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: getHeight(context, 16),
              horizontal: getWidth(context, isTablet ? 20 : 16),
            ),
            labelText: 'Description (Optional)',
            alignLabelWithHint: true,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.primaryColor, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}
