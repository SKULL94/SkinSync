import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:skin_sync/model/custom_routine.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/modules/routine/widgets/routine_screen_widget/build_time_section.dart';
import 'package:skin_sync/modules/routine/widgets/routine_screen_widget/routine_card.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class RoutineScreenRoutineList extends StatelessWidget {
  final RoutineController controller;
  const RoutineScreenRoutineList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filteredRoutines = controller.filteredRoutines;

      Map<String, List<CustomRoutine>> routineGroups = {
        'Morning Routine': [],
        'Afternoon Routine': [],
        'Evening Routine': [],
        'Night Routine': [],
      };

      for (CustomRoutine r in filteredRoutines) {
        final int hour = r.time.hour;
        if (hour >= 5 && hour < 12) {
          routineGroups['Morning Routine']!.add(r);
        } else if (hour >= 12 && hour < 17) {
          routineGroups['Afternoon Routine']!.add(r);
        } else if (hour >= 17 && hour < 21) {
          routineGroups['Evening Routine']!.add(r);
        } else {
          routineGroups['Night Routine']!.add(r);
        }
      }

      final sections = [
        {
          'title': 'Morning Routine',
          'icon': Icons.wb_sunny_rounded,
          'routines': routineGroups['Morning Routine'],
        },
        {
          'title': 'Afternoon Routine',
          'icon': Icons.brightness_5_rounded,
          'routines': routineGroups['Afternoon Routine'],
        },
        {
          'title': 'Evening Routine',
          'icon': Icons.nightlight_round_rounded,
          'routines': routineGroups['Evening Routine'],
        },
        {
          'title': 'Night Routine',
          'icon': Icons.bedtime_rounded,
          'routines': routineGroups['Night Routine'],
        },
      ].where((s) => (s['routines'] as List).isNotEmpty).toList();

      final totalItems = sections.fold(
        0,
        (sum, section) => sum + 1 + (section['routines'] as List).length,
      );

      return ListView.separated(
        padding: EdgeInsets.symmetric(
          vertical: getHeight(context, 16),
          horizontal: getHeight(context, 16),
        ),
        itemCount: totalItems,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          int currentIndex = 0;
          for (Map<String, Object?> section in sections) {
            final routines = section['routines'] as List<CustomRoutine>;
            final sectionItemCount = 1 + routines.length;
            if (index < currentIndex + sectionItemCount) {
              final pos = index - currentIndex;
              if (pos == 0) {
                return RoutineScreenTimeSection(
                    title: section['title'] as String,
                    icon: section['icon'] as IconData);
              } else {
                return RoutineScreenRoutineCard(
                  routine: routines[pos - 1],
                  controller: controller,
                );
              }
            }
            currentIndex += sectionItemCount;
          }
          return const SizedBox.shrink();
        },
      );
    });
  }
}
