import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/streaks/streaks_controller.dart';
import 'package:skin_sync/routes/app_routes.dart';

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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStreakTypeSelector(controller),
              const SizedBox(height: 20),
              _buildHeader(controller),
              const SizedBox(height: 20),
              _buildStreakCard(controller, size),
              const SizedBox(height: 30),
              _buildChartSection(controller, size),
              const SizedBox(height: 20),
              _buildMotivationSection(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStreakTypeSelector(StreaksController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStreakTypeButton(
                label: 'Daily',
                isActive:
                    controller.currentStreakType.value == StreakType.daily,
                onTap: () => controller.changeStreakType(StreakType.daily),
              ),
              _buildStreakTypeButton(
                label: 'Weekly',
                isActive:
                    controller.currentStreakType.value == StreakType.weekly,
                onTap: () => controller.changeStreakType(StreakType.weekly),
              ),
              _buildStreakTypeButton(
                label: 'Perfect',
                isActive:
                    controller.currentStreakType.value == StreakType.monthly,
                onTap: () => controller.changeStreakType(StreakType.monthly),
              ),
            ],
          )),
    );
  }

  Widget _buildStreakTypeButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xff964F66) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
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
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(StreaksController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Streak',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${controller.streaks} day${controller.streaks == 1 ? '' : 's'}',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Color(0xff964F66),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(StreaksController controller, Size size) {
    return Container(
      width: size.width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffF2E8EB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            '🔥 Active Streak',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff964F66),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${controller.streaks} day${controller.streaks == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: controller.streaks / 30,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff964F66)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(StreaksController controller, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly Progress',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
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

  Widget _buildMotivationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffF2E8EB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Keep the streak alive!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff964F66),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Complete your routines daily to maintain your streak',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff964F66),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'View Routines',
              style: TextStyle(
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
