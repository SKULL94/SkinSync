import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/history/skin_analysis_history_screen.dart';
import 'package:skin_sync/modules/routine/routine_screen.dart';
import 'package:skin_sync/modules/streaks/streaks_screen.dart';

class LayoutController extends GetxController {
  final List<StatelessWidget> bodyPages = [
    RoutineScreen(),
    StreaksScreen(),
    HistoryScreen()
  ];
  final RxInt _currentIndex = RxInt(0);

  int get currentIndex => _currentIndex.value;

  changeIndex(int value) {
    _currentIndex.value = value;
    update();
  }
}
