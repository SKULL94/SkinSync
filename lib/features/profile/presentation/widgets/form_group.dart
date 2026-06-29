import 'package:flutter/material.dart';
import 'package:skin_sync/core/constants/color_const.dart';

class FormGroup extends StatelessWidget {
  final List<Widget> rows;

  const FormGroup({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 18),
                color: AppColors.hairline,
              ),
          ],
        ],
      ),
    );
  }
}
