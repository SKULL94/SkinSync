import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/layout/layout_controller.dart';
import 'package:skin_sync/modules/layout/widgets/nav_bar_widget.dart';

class LayoutScreen extends StatelessWidget {
  const LayoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final layoutController = Get.put(LayoutController());

    return Scaffold(
      bottomNavigationBar: Container(
        height: 75,
        color: const Color(0xffF2E8EB),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: CustomizedNavBarWidget(
                  title: "Routine",
                  icon: layoutController.currentIndex == 0
                      ? Icons.home
                      : Icons.home_outlined,
                  index: 0,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                  flex: 1,
                  child: CustomizedNavBarWidget(
                      title: "Streaks",
                      icon: layoutController.currentIndex == 1
                          ? Icons.people_alt
                          : Icons.people_alt_outlined,
                      index: 1)),
            ],
          ),
        ),
      ),
      body: Obx(
        () => layoutController.bodyPages[layoutController.currentIndex],
      ),
    );
  }
}
