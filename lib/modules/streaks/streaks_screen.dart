import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/streaks/streaks_controller.dart';
import 'package:skin_sync/routes/app_routes.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class StreaksScreen extends StatelessWidget {
  StreaksScreen({super.key});

  final StreaksController controller = Get.put(StreaksController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xffFCF7FA),
      appBar: AppBar(
        title: const Text('Streaks'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Get.offAllNamed(AppRoutes.authRoute),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isFetchingStreaksData) {
          return Center(
              child: CircularProgressIndicator(color: theme.primaryColor));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              vertical: getHeight(context, 16),
              horizontal: getWidth(context, 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStreakTypeSelector(controller, context),
              SizedBox(height: getHeight(context, 20)),
              _buildHeader(controller, context),
              SizedBox(height: getHeight(context, 20)),
              _buildStreakCard(controller, size, context),
              SizedBox(height: getHeight(context, 30)),
              _buildChartSection(controller, size, isTablet(context), context),
              SizedBox(height: getHeight(context, 30)),
              _buildMotivationSection(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStreakTypeSelector(
      StreaksController controller, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: getHeight(context, 16), horizontal: getWidth(context, 16)),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStreakTypeButton(
                  label: 'Daily',
                  isActive:
                      controller.currentStreakType.value == StreakType.daily,
                  onTap: () => controller.changeStreakType(StreakType.daily),
                  context: context),
              _buildStreakTypeButton(
                  label: 'Weekly',
                  isActive:
                      controller.currentStreakType.value == StreakType.weekly,
                  onTap: () => controller.changeStreakType(StreakType.weekly),
                  context: context),
              _buildStreakTypeButton(
                  label: 'Perfect',
                  isActive:
                      controller.currentStreakType.value == StreakType.monthly,
                  onTap: () => controller.changeStreakType(StreakType.monthly),
                  context: context),
            ],
          )),
    );
  }

  Widget _buildStreakTypeButton(
      {required String label,
      required bool isActive,
      required VoidCallback onTap,
      required BuildContext context}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: getHeight(context, 16),
            horizontal: getWidth(context, 16)),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xff964F66) : Colors.transparent,
          borderRadius: BorderRadius.circular(getWidth(context, 20)),
          border: Border.all(
            color: const Color(0xff964F66),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: isActive ? Colors.white : const Color(0xff964F66),
              fontWeight: FontWeight.w500,
              fontSize: getResponsiveFontSize(context, 14)),
        ),
      ),
    );
  }

  Widget _buildHeader(StreaksController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Streak',
          style: TextStyle(
            fontSize: getResponsiveFontSize(context, 24),
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: getHeight(context, 8)),
        Text(
          '${controller.streaks} day${controller.streaks == 1 ? '' : 's'}',
          style: TextStyle(
            fontSize: getResponsiveFontSize(context, 36),
            fontWeight: FontWeight.w900,
            color: const Color(0xff964F66),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(
      StreaksController controller, Size size, BuildContext context) {
    return Container(
      width: size.width,
      padding: EdgeInsets.symmetric(
          vertical: getHeight(context, 20), horizontal: getWidth(context, 20)),
      decoration: BoxDecoration(
        color: const Color(0xffF2E8EB),
        borderRadius: BorderRadius.circular(getWidth(context, 16)),
      ),
      child: Column(
        children: [
          Text(
            '🔥 Active Streak',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: const Color(0xff964F66),
            ),
          ),
          SizedBox(height: getHeight(context, 12)),
          Text(
            '${controller.streaks} day${controller.streaks == 1 ? '' : 's'}',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context, 32),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: getHeight(context, 8)),
          LinearProgressIndicator(
            value: controller.streaks / 30,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff964F66)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(getWidth(context, 4)),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(StreaksController controller, Size size,
      bool isTablet, BuildContext context) {
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
          height: getHeight(context, isTablet ? 120 : 100),
          child: LineChart(
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
                  color: const Color(0xff964F66),
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xff964F66).withValues(alpha: 0.1),
                  ),
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          vertical: getHeight(context, 20), horizontal: getWidth(context, 20)),
      decoration: BoxDecoration(
        color: const Color(0xffF2E8EB),
        borderRadius: BorderRadius.circular(getWidth(context, 16)),
      ),
      child: Column(
        children: [
          Text(
            'Keep the streak alive!',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: const Color(0xff964F66),
            ),
          ),
          SizedBox(height: getHeight(context, 12)),
          Text(
            'Complete your routines daily to maintain your streak',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: getResponsiveFontSize(context, 14),
              color: Colors.grey,
            ),
          ),
          SizedBox(height: getHeight(context, 16)),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff964F66),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(getWidth(context, 12)),
              ),
              padding: EdgeInsets.symmetric(
                  vertical: getHeight(context, 12),
                  horizontal: getWidth(context, 24)),
            ),
            child: Text(
              'View Routines',
              style: TextStyle(
                fontSize: getResponsiveFontSize(context, 14),
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
