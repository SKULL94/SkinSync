import 'package:flutter/material.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class CustomRoutineTimeSelector extends StatelessWidget {
  const CustomRoutineTimeSelector(
      {super.key, required this.onSelectTime, required this.selectedTime});

  final VoidCallback onSelectTime;
  final TimeOfDay selectedTime;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelectTime,
      child: Container(
        padding: EdgeInsets.all(getWidth(context, 16)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(getWidth(context, 15)),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_rounded,
                color: Theme.of(context).primaryColor,
                size: getWidth(context, 24)),
            SizedBox(width: getWidth(context, 15)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Routine Time',
                    style: TextStyle(
                        fontSize: getResponsiveFontSize(context, 13))),
                SizedBox(height: getHeight(context, 4)),
                Text(selectedTime.format(context),
                    style: TextStyle(
                      fontSize: getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
            const Spacer(),
            Text(
              'Change',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: getResponsiveFontSize(context, 14)),
            ),
          ],
        ),
      ),
    );
  }
}
