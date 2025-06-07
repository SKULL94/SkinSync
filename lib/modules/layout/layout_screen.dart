import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/layout/layout_controller.dart';
import 'package:skin_sync/modules/layout/widgets/nav_bar_widget.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class LayoutScreen extends StatelessWidget {
  LayoutScreen({Key? key}) : super(key: key);
  final LayoutController layoutController = Get.find();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      bottomNavigationBar: SizedBox(
        height: getHeight(context, 75),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: CustomizedNavBarWidget(
                  theme: theme,
                  title: "Routine",
                  icon: layoutController.currentIndex == 0
                      ? Icons.home
                      : Icons.home_outlined,
                  index: 0,
                ),
              ),
              SizedBox(width: getWidth(context, 10)),
              Expanded(
                  flex: 1,
                  child: CustomizedNavBarWidget(
                      theme: theme,
                      title: "Streaks",
                      icon: layoutController.currentIndex == 1
                          ? Icons.people_alt
                          : Icons.people_alt_outlined,
                      index: 1)),
              SizedBox(width: getWidth(context, 10)),
              Expanded(
                  flex: 1,
                  child: CustomizedNavBarWidget(
                      theme: theme,
                      title: "History",
                      icon: layoutController.currentIndex == 2
                          ? Icons.history
                          : Icons.history_outlined,
                      index: 2)),
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
