import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/streaks/streaks_controller.dart';
import 'package:skin_sync/routes/app_routes.dart';
import 'package:skin_sync/utils/storage.dart';

class StreaksScreen extends StatelessWidget {
  const StreaksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StreaksController streaksController = Get.put(StreaksController());
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xffFCF7FA),
      appBar: AppBar(
        title: const Text('Streaks'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              StorageService.instance.clearAll();
              Get.offAllNamed(AppRoutes.authRoute);
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Obx(
            () => streaksController.isFetchingStreaksData
                ? SizedBox(
                    height: size.height,
                    width: size.width,
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                          text: TextSpan(
                        text: streaksController.streaks + 1 == 1
                            ? "Today's Goal: ${streaksController.streaks + 1} streak day"
                            : "Today's Goal: ${streaksController.streaks + 1} streak days",
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      )),
                      const SizedBox(height: 20),
                      Container(
                          // height: size.height * 0.2,
                          width: size.width,
                          decoration: BoxDecoration(
                            color: const Color(0xffF2E8EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Streak Days",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  streaksController.streaks.toString(),
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 30),
                      const Text(
                        "Daily Streak",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        streaksController.streaks.toString(),
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: const TextSpan(
                            text: "Last 30 Days ",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff964F66),
                            ),
                            children: [
                              TextSpan(
                                  text: "+100%",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.green))
                            ]),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                          height: size.height * 0.32,
                          width: size.width,
                          child: Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 1.70,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 18,
                                    left: 12,
                                    top: 24,
                                    bottom: 12,
                                  ),
                                  child: LineChart(
                                    streaksChartData(),
                                  ),
                                ),
                              ),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("1D",
                                      style: TextStyle(
                                          color: Color(0xFF964F44),
                                          fontWeight: FontWeight.w600)),
                                  Text("1W",
                                      style: TextStyle(
                                          color: Color(0xFF964F44),
                                          fontWeight: FontWeight.w600)),
                                  Text("1M",
                                      style: TextStyle(
                                          color: Color(0xFF964F44),
                                          fontWeight: FontWeight.w600)),
                                  Text("3M",
                                      style: TextStyle(
                                          color: Color(0xFF964F44),
                                          fontWeight: FontWeight.w600)),
                                  Text("1Y",
                                      style: TextStyle(
                                          color: Color(0xFF964F44),
                                          fontWeight: FontWeight.w600)),
                                ],
                              )
                            ],
                          )),

                      const SizedBox(height: 10),
                      const Text(
                        "Keep it up! You're on a roll.",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      // elevated button
                      SizedBox(
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffF2E8EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

LineChartData streaksChartData() {
  return LineChartData(
    gridData: const FlGridData(
        horizontalInterval: 2, verticalInterval: 1, show: false),
    titlesData: const FlTitlesData(
      show: true,
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      // AxisTitles(
      //   sideTitles: SideTitles(
      //     showTitles: true,
      //     reservedSize: 30,
      //     interval: 1,
      //     getTitlesWidget: bottomTitleWidgets,
      //   ),
      // ),
    ),
    borderData: FlBorderData(
      show: false,
    ),
    minX: 0,
    maxX: 11,
    minY: 0,
    maxY: 6,
    lineBarsData: [
      LineChartBarData(
        spots: const [
          FlSpot(0, 3),
          FlSpot(1, 6),
          FlSpot(2.6, 2),
          FlSpot(4.9, 5),
          FlSpot(6.8, 3.1),
          FlSpot(8, 4),
          FlSpot(9.5, 3),
          FlSpot(11, 4),
        ],
        isCurved: true,
        barWidth: 3,
        color: const Color(0xff964F66),
        isStrokeCapRound: false,
        dotData: const FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: false,
        ),
      ),
    ],
  );
}
