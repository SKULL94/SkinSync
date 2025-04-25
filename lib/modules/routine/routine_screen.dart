import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:skin_sync/model/custom_routine.dart';
import 'package:skin_sync/modules/routine/custom_routine_screen.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/utils/storage.dart';

class RoutineScreen extends StatelessWidget {
  RoutineScreen({super.key});

  final RoutineController controller = Get.put(RoutineController());
  final DateFormat dateFormat = DateFormat('EEE, MMM d');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Welcome, ${StorageService.instance.fetch('userName') ?? 'Zeeshan'} 👋',
            style: const TextStyle(fontWeight: FontWeight.w500)),
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
          backgroundColor:
              isPastDate ? Colors.grey : Theme.of(context).secondaryHeaderColor,
        );
      }),
      body: Column(
        children: [
          _buildDateNavigation(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }
              return controller.routines.isEmpty
                  ? _buildEmptyState()
                  : _buildRoutineList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDateNavigation() {
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
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Completed: ${controller.completedRoutinesCount}',
                    style: TextStyle(
                        color: Colors.green[700], fontWeight: FontWeight.w500),
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

  Widget _buildRoutineList() {
    return Obx(() {
      final filteredRoutines = controller.filteredRoutines;

      final morningRoutines = filteredRoutines.where((r) {
        final hour = r.time.hour;
        return hour >= 5 && hour < 12;
      }).toList();

      final afternoonRoutines = filteredRoutines.where((r) {
        final hour = r.time.hour;
        return hour >= 12 && hour < 17;
      }).toList();

      final eveningRoutines = filteredRoutines.where((r) {
        final hour = r.time.hour;
        return hour >= 17 && hour < 21;
      }).toList();

      final nightRoutines = filteredRoutines.where((r) {
        final hour = r.time.hour;
        return hour >= 21 || hour < 5;
      }).toList();

      final sections = [
        {
          'title': 'Morning Routine',
          'icon': Icons.wb_sunny_rounded,
          'routines': morningRoutines,
        },
        {
          'title': 'Afternoon Routine',
          'icon': Icons.brightness_5_rounded,
          'routines': afternoonRoutines,
        },
        {
          'title': 'Evening Routine',
          'icon': Icons.nightlight_round_rounded,
          'routines': eveningRoutines,
        },
        {
          'title': 'Night Routine',
          'icon': Icons.bedtime_rounded,
          'routines': nightRoutines,
        },
      ];

      final nonEmptySections =
          sections.where((s) => (s['routines'] as List).isNotEmpty).toList();

      int totalItems = nonEmptySections.fold(
          0, (sum, section) => sum + 1 + (section['routines'] as List).length);

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: totalItems,
        separatorBuilder: (_, i) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          int current = 0;
          for (var section in nonEmptySections) {
            final routines = section['routines'] as List<CustomRoutine>;
            final sectionItemCount = 1 + routines.length;
            if (index < current + sectionItemCount) {
              final posInSection = index - current;
              if (posInSection == 0) {
                return _buildTimeSection(
                    section['title'] as String, section['icon'] as IconData);
              } else {
                final routineIndex = posInSection - 1;
                return _buildRoutineCard(routines[routineIndex]);
              }
            }
            current += sectionItemCount;
          }
          return const SizedBox.shrink();
        },
      );
    });
  }

  Widget _buildTimeSection(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.amber[700]),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(CustomRoutine routine) {
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
          padding: const EdgeInsets.only(right: 20),
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
          borderRadius: BorderRadius.circular(15),
          onTap: () => controller.toggleRoutineCompletion(routine.id),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildProgressIndicator(routine),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(routine.name,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                                if (routine.description.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(routine.description,
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14)),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (routine.imagePath.isNotEmpty)
                        _buildRoutineImage(routine),
                      const SizedBox(height: 12),
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
                                size: 18,
                                color: isCompleted
                                    ? Colors.green[800]
                                    : Colors.grey[600]),
                          ),
                          Text(routine.time.format(Get.context!),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: timeColor)),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(Icons.close_rounded,
                        size: 20, color: Colors.grey[500]),
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

  Widget _buildProgressIndicator(CustomRoutine routine) {
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
          size: 22,
          color: Theme.of(Get.context!).primaryColor,
        ),
      ],
    );
  }

  Widget _buildRoutineImage(CustomRoutine routine) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: routine.imagePath,
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: Colors.grey[100],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (_, __, ___) => Container(
          color: Colors.grey[100],
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.grey),
              Text('Failed to load image',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text('Loading your routines...',
            style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Lottie.asset(
            'assets/images/Main Scene.json',
            width: 250,
            height: 250,
            repeat: true,
            frameRate: const FrameRate(60),
          ),
          const SizedBox(height: 15),
          Text("No Routines Found",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text("Tap the + button to create your first routine!",
              style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}
