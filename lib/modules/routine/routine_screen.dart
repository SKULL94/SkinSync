import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:skin_sync/model/custom_routine.dart';
import 'package:skin_sync/modules/routine/custom_routine_screen.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/utils/mediaquery.dart';
import 'package:skin_sync/utils/storage.dart';

class RoutineScreen extends StatelessWidget {
  RoutineScreen({super.key});

  final RoutineController controller = Get.find<RoutineController>();
  final DateFormat dateFormat = DateFormat('EEE, MMM d');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, ${StorageService.instance.fetch('userName') ?? 'Zeeshan'} 👋',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: getResponsiveFontSize(context, 18),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              final newTheme = Get.isDarkMode ? 'light' : 'dark';
              Get.changeThemeMode(
                  newTheme == 'dark' ? ThemeMode.dark : ThemeMode.light);
              StorageService.instance.save('theme', newTheme);
            },
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        final today = DateTime.now();
        final selectedDate = controller.selectedDate.value;
        final isPastDate =
            selectedDate.isBefore(DateTime(today.year, today.month, today.day));
        return FloatingActionButton.extended(
          icon: const Icon(Icons.add_task_rounded),
          label: const Text("New Routine"),
          onPressed: isPastDate
              ? null
              : () => Get.to(() => const CreateRoutineScreen()),
        );
      }),
      body: Column(
        children: [
          _buildDateNavigation(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState(context);
              }
              return controller.routines.isEmpty
                  ? _buildEmptyState(context)
                  : _buildRoutineList(context);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDateNavigation(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => controller.selectedDate.value = controller
                    .selectedDate.value
                    .subtract(const Duration(days: 1)),
              ),
              Column(
                children: [
                  Text(
                    dateFormat.format(controller.selectedDate.value),
                    style: TextStyle(
                        fontSize: getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Completed: ${controller.completedRoutinesCount}',
                    style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                        fontSize: getResponsiveFontSize(context, 14)),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => controller.selectedDate.value =
                    controller.selectedDate.value.add(const Duration(days: 1)),
              ),
            ],
          )),
    );
  }

  Widget _buildRoutineList(BuildContext context) {
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
                return _buildTimeSection(section['title'] as String,
                    section['icon'] as IconData, context);
              } else {
                return _buildRoutineCard(routines[pos - 1], context);
              }
            }
            currentIndex += sectionItemCount;
          }
          return const SizedBox.shrink();
        },
      );
    });
  }

  Widget _buildTimeSection(String title, IconData icon, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: getHeight(context, 8)),
      child: Row(
        children: [
          Icon(icon, size: getHeight(context, 20), color: Colors.amber[700]),
          SizedBox(width: getWidth(context, 8)),
          Text(title,
              style: TextStyle(
                  fontSize: getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(CustomRoutine routine, BuildContext context) {
    final isCompleted = controller.isDateCompleted(routine);
    final timeColor =
        isCompleted ? Colors.green[700] : Theme.of(Get.context!).primaryColor;
    return Obx(() {
      final selectedDate = controller.selectedDate.value;
      return Dismissible(
        key: Key('${routine.id}-${selectedDate.toIso8601String()}'),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: getHeight(context, 20)),
          child:
              const Icon(Icons.delete_forever, color: Colors.white, size: 30),
        ),
        confirmDismiss: (_) async {
          return await Get.dialog(AlertDialog(
            title: const Text("Delete Routine?"),
            content:
                const Text("Are you sure you want to delete this routine?"),
            actions: [
              TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () => Get.back(result: true),
                  child: const Text("Delete",
                      style: TextStyle(color: Colors.red))),
            ],
          ));
        },
        onDismissed: (_) => controller.deleteRoutine(routine.id),
        child: InkWell(
          borderRadius: BorderRadius.circular(getWidth(context, 15)),
          onTap: () => controller.toggleRoutineCompletion(routine.id),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(getWidth(context, 15)),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: getHeight(context, 16),
                      horizontal: getWidth(context, 16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildProgressIndicator(routine, context),
                          SizedBox(width: getWidth(context, 16)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(routine.name,
                                    style: TextStyle(
                                        fontSize:
                                            getResponsiveFontSize(context, 14),
                                        fontWeight: FontWeight.w600)),
                                if (routine.description.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: getHeight(context, 4)),
                                    child: Text(routine.description,
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: getResponsiveFontSize(
                                                context, 14))),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: getHeight(context, 12)),
                      if (routine.imagePath.isNotEmpty)
                        _buildRoutineImage(routine, context),
                      SizedBox(height: getHeight(context, 12)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            backgroundColor: isCompleted
                                ? Colors.green[50]
                                : Colors.grey[100],
                            label: Text(isCompleted ? "Completed" : "Pending",
                                style: TextStyle(
                                    color: isCompleted
                                        ? Colors.green[800]
                                        : Colors.grey[600])),
                            avatar: Icon(
                                isCompleted ? Icons.check : Icons.access_time,
                                size: getHeight(context, 18),
                                color: isCompleted
                                    ? Colors.green[800]
                                    : Colors.grey[600]),
                          ),
                          Text(routine.time.format(Get.context!),
                              style: TextStyle(
                                  fontSize: getResponsiveFontSize(context, 16),
                                  fontWeight: FontWeight.w600,
                                  color: timeColor)),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: getHeight(context, 16),
                  right: getHeight(context, 16),
                  child: IconButton(
                    icon: Icon(Icons.close_rounded,
                        size: getHeight(context, 20), color: Colors.grey[500]),
                    onPressed: () => controller.deleteRoutine(routine.id),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildProgressIndicator(CustomRoutine routine, BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: routine.completionProgress,
          strokeWidth: 3,
          color: Theme.of(Get.context!).primaryColor,
          backgroundColor: Colors.grey[200],
        ),
        Icon(
          routine.localIconPath.isEmpty
              ? Icons.self_improvement_rounded
              : Icons.checklist_rounded,
          size: getHeight(context, 22),
          color: Theme.of(Get.context!).primaryColor,
        ),
      ],
    );
  }

  Widget _buildRoutineImage(CustomRoutine routine, BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: routine.imagePath,
        width: double.infinity,
        height: getHeight(context, 150),
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: Colors.grey[100],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (_, __, ___) => Container(
          color: Colors.grey[100],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.grey),
              Text('Failed to load image',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: getResponsiveFontSize(context, 14))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        SizedBox(height: getHeight(context, 16)),
        Text('Loading your routines...',
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: getResponsiveFontSize(context, 14))),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Lottie.asset(
            'assets/images/Main Scene.json',
            width: getHeight(context, 250),
            height: getHeight(context, 250),
            repeat: true,
            frameRate: const FrameRate(60),
          ),
          SizedBox(height: getHeight(context, 15)),
          Text("No Routines Found",
              style: TextStyle(
                  fontSize: getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const Text("Tap the + button to create your first routine!"),
        ],
      ),
    );
  }
}
