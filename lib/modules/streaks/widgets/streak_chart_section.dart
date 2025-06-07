import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/streaks/streaks_controller.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class StreakChartSection extends StatelessWidget {
  final StreaksController controller;

  const StreakChartSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Progress',
          style: TextStyle(
            fontSize: getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: getHeight(context, 50)),
        SizedBox(
          height: getHeight(
              context, MediaQuery.of(context).size.width > 600 ? 120 : 100),
          child: Obx(() => LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 29,
                  minY: 0,
                  maxY: controller.streaks.toDouble() + 2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: controller.getStreakChartData(),
                      isCurved: true,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: true),
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              )),
        ),
      ],
    );
  }
}
