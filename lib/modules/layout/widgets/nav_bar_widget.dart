import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/layout/layout_controller.dart';

class CustomizedNavBarWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final int index;
  final ThemeData theme;

  const CustomizedNavBarWidget(
      {super.key,
      required this.title,
      required this.icon,
      required this.index,
      required this.theme});

  @override
  Widget build(BuildContext context) {
    final LayoutController layoutController = Get.find();
    return InkWell(
      onTap: () => layoutController.changeIndex(index),
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(
          color: index == layoutController.currentIndex
              ? theme.primaryColor
              : Colors.transparent,
          width: 3,
        ))),
        child: AnimatedContainer(
          curve: Curves.fastOutSlowIn,
          padding: const EdgeInsets.symmetric(vertical: 8),
          duration: const Duration(milliseconds: 500),
          child: Column(
            children: [
              Obx(() => Icon(
                    icon,
                    color: index != layoutController.currentIndex
                        ? Colors.grey
                        : theme.primaryColor,
                  )),
              const SizedBox(height: 2),
              Obx(() => Text(
                    title.toUpperCase(),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: index != layoutController.currentIndex
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: index != layoutController.currentIndex
                            ? Colors.grey
                            : theme.primaryColor),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
