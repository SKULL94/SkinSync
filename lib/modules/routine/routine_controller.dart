import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skin_sync/model/custom_routine.dart';
import 'package:skin_sync/routes/app_routes.dart';
import 'package:skin_sync/services/firestore_queue.dart';
import 'package:skin_sync/services/notification_service.dart';
import 'package:skin_sync/utils/app_constants.dart';
import 'package:skin_sync/utils/custom_snackbar.dart';
import 'package:skin_sync/services/image_service.dart';
import 'package:skin_sync/services/storage.dart';
import 'package:uuid/uuid.dart';

class RoutineController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = const Uuid();
  final RxBool isImageLoading = false.obs;

  final RxList<CustomRoutine> routines = <CustomRoutine>[].obs;
  final RxList<CustomRoutine> filteredRoutines = <CustomRoutine>[].obs;
  final RxBool isLoading = false.obs;
  final NotificationService notificationService = Get.find();

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;
  final Rx<File?> localIcon = Rx<File?>(null);
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  String? get _userId => StorageService.instance.fetch(AppConstants.userId);
  CollectionReference get _userRoutines =>
      _firestore.collection('users').doc(_userId).collection('routines');

  @override
  void onInit() {
    super.onInit();
    selectedDate.listen((_) => _filterRoutines());
    fetchRoutines();
    _rescheduleAllNotifications();
  }

  Future<void> _rescheduleAllNotifications() async {
    for (final routine in routines) {
      await notificationService.scheduleCustomRoutine(routine);
    }
  }

  Future<XFile?> pickImage(ImageSource source) async {
    isImageLoading.value = true;
    try {
      final pickedFile = await ImageService.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        localIcon.value = File(pickedFile.path);
        return pickedFile;
      }
    } catch (e) {
      showCustomSnackbar("Error", "Failed to pick image: $e");
    } finally {
      isImageLoading.value = false;
    }
    return null;
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).primaryColor,
            secondary: Theme.of(context).primaryColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) selectedTime.value = picked;
  }

  Future<void> selectDate(BuildContext context,
      {required bool isStartDate}) async {
    final initialDate =
        isStartDate ? startDate.value : endDate.value ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      isStartDate ? startDate.value = picked : endDate.value = picked;
    }
  }

  Future<void> saveRoutine() async {
    if (_userId == null) return;
    try {
      final routineId = _uuid.v4();
      final iconPath = await _saveLocalIcon(routineId);

      final newRoutine = CustomRoutine(
        id: routineId,
        name: nameController.text.trim(),
        description: descController.text.trim(),
        time: selectedTime.value,
        userId: _userId!,
        createdDate: DateTime.now().toLocal(),
        imagePath: '',
        localIconPath: iconPath ?? '',
        startDate: startDate.value.toLocal(),
        endDate: endDate.value?.toLocal(),
        completionDates: [],
      );

      routines.add(newRoutine);
      _filterRoutines();
      // final notificationService = Get.find<NotificationService>();
      // await notificationService.scheduleCustomRoutines(routines.toList());
      _showSuccess('Routine created successfully!');
      //check for navigation stack
      Get.offNamed(AppRoutes.layoutRoute);

      final firestoreQueue = FirestoreQueueService();
      final routineMap = newRoutine.toMap();
      firestoreQueue.addToQueue(
        'set',
        'users/$_userId/routines',
        routineId,
        routineMap,
      );
      await _userRoutines.doc(routineId).set(routineMap);
      await notificationService.scheduleCustomRoutine(newRoutine);
    } catch (e) {
      showCustomSnackbar('Error', "Failed to save routine: $e");
    }
  }

  Future<void> fetchRoutines() async {
    if (_userId == null) return;

    try {
      isLoading.value = true;
      final query = _userRoutines.orderBy('createdDate');

      final cachedSnapshot =
          await query.get(const GetOptions(source: Source.cache));
      if (cachedSnapshot.docs.isNotEmpty) {
        _processSnapshot(cachedSnapshot);
      }

      final serverSnapshot =
          await query.get(const GetOptions(source: Source.server));
      if (serverSnapshot.docs.isNotEmpty) {
        _processSnapshot(serverSnapshot);
      }
      // await NotificationService().scheduleCustomRoutines(routines.toList());
    } catch (e) {
      debugPrint("Error fetching routines: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _processSnapshot(QuerySnapshot snapshot) {
    routines.assignAll(snapshot.docs.map((d) {
      final data = d.data()! as Map<String, dynamic>;
      return CustomRoutine.fromMap({...data, 'id': d.id});
    }));
    _filterRoutines();
  }

  Future<void> toggleRoutineCompletion(String routineId) async {
    try {
      final int index = routines.indexWhere((r) => r.id == routineId);
      if (index == -1) return;

      final updated = routines[index].toggleCompletion(selectedDate.value);
      routines[index] = updated;
      _filterRoutines();

      final firestoreQueue = FirestoreQueueService();
      firestoreQueue.addToQueue(
        'update',
        'users/$_userId/routines',
        routineId,
        {
          'completionDates': updated.completionDates
              .map((d) => Timestamp.fromDate(d))
              .toList(),
        },
      );
    } catch (e) {
      showCustomSnackbar('Error', "Failed to toggle completion: $e");
    }
  }

  // double get overallProgress {
  //   if (filteredRoutines.isEmpty) return 0.0;
  //   final totalProgress = filteredRoutines.fold(
  //       0.0, (sum, routine) => sum + routine.completionProgress);
  //   return totalProgress / filteredRoutines.length;
  // }

  Future<void> deleteRoutine(String id) async {
    if (_userId == null) return;
    try {
      final idString = id.toString();
      if (idString.contains('-')) {
        await _userRoutines.doc(idString).delete();
        routines.removeWhere((r) => r.id == idString);
        _filterRoutines();
      }
      final notificationId = int.tryParse(idString);
      if (notificationId != null) {
        await notificationService.cancelNotification(notificationId);
      }
      // final routine = routines.firstWhere((r) => r.id == id);
    } catch (e) {
      showCustomSnackbar('Error', "Failed to delete routine: $e");
    }
  }

  bool isDateCompleted(CustomRoutine routine) {
    return routine.isCompletedOnDate(selectedDate.value);
  }

  int get completedCount {
    return filteredRoutines.where((r) => isDateCompleted(r)).length;
  }

  Future<String?> _saveLocalIcon(String routineId) async {
    if (localIcon.value == null) return null;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final iconDir = Directory('${directory.path}/routine_icons');
      if (!await iconDir.exists()) await iconDir.create(recursive: true);

      final path = '${iconDir.path}/$routineId.png';
      await localIcon.value!.copy(path);
      return path;
    } catch (e) {
      showCustomSnackbar('Error', "Failed to save icon: $e");
      return null;
    }
  }

  void _filterRoutines() {
    filteredRoutines.value = routines.where((routine) {
      final selected = selectedDate.value;
      final start = DateTime(routine.startDate.year, routine.startDate.month,
          routine.startDate.day);
      final end = routine.endDate != null
          ? DateTime(routine.endDate!.year, routine.endDate!.month,
              routine.endDate!.day)
          : null;

      return end == null
          ? _isSameDay(start, selected)
          : selected.isAfter(start.subtract(const Duration(days: 1))) &&
              selected.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showSuccess(String message) => Get.showSnackbar(
        GetSnackBar(
          message: message,
          duration: 2.seconds,
          backgroundColor: Colors.green[400]!,
          snackPosition: SnackPosition.TOP,
          borderRadius: 8,
          margin: const EdgeInsets.all(16),
        ),
      );
}
