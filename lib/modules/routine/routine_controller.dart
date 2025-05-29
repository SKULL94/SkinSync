import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skin_sync/utils/custom_snackbar.dart';
import 'package:skin_sync/model/custom_routine.dart';
import 'package:skin_sync/modules/layout/layout_screen.dart';
import 'package:skin_sync/utils/app_utils.dart';
import 'package:skin_sync/utils/notification_service.dart';
import 'package:skin_sync/utils/storage.dart';
import 'package:uuid/uuid.dart';

/// Controller for managing skincare routines
///
/// Handles:
/// - CRUD operations for routines
/// - Image selection for routine icons
/// - Time/date selection for routines
/// - Routine completion tracking
/// - Notification scheduling
/// - Filtering routines by selected date
class RoutineController extends GetxController {
  // ==============================
  // Dependencies
  // ==============================
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService =
      Get.find<NotificationService>();
  final Uuid _uuid = const Uuid();

  // ==============================
  // State Variables
  // ==============================

  /// Tracks loading state during image selection
  final RxBool isImageLoading = false.obs;

  /// Tracks loading state during data fetching
  final RxBool isLoading = false.obs;

  /// List of all routines for current user
  final RxList<CustomRoutine> routines = <CustomRoutine>[].obs;

  /// Routines filtered by currently selected date
  final RxList<CustomRoutine> filteredRoutines = <CustomRoutine>[].obs;

  // ==============================
  // Form Controllers
  // ==============================

  /// Controls routine name input field
  final TextEditingController nameController = TextEditingController();

  /// Controls routine description input field
  final TextEditingController descController = TextEditingController();

  /// Selected time for routine notifications
  final Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;

  /// Local file for routine icon image
  final Rx<File?> localIcon = Rx<File?>(null);

  /// Start date for routine schedule
  final Rx<DateTime> startDate = DateTime.now().obs;

  /// Optional end date for routine schedule
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);

  /// Currently selected date in calendar view
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // ==============================
  // Helper Getters
  // ==============================

  /// Gets current user ID from secure storage
  String get _userId => StorageService.instance.fetch(AppUtils.userId);

  /// Reference to user's routines collection in Firestore
  CollectionReference get _userRoutines =>
      _firestore.collection('users').doc(_userId).collection('routines');

  @override
  void onInit() {
    super.onInit();
    _setupReactiveListeners();
  }

  /// Sets up reactive listeners for state changes
  void _setupReactiveListeners() {
    selectedDate.listen((_) => _filterRoutines());
  }

  // ==============================
  // Image Handling
  // ==============================

  /// Picks an image from device gallery or camera
  ///
  /// [source]: ImageSource.gallery or ImageSource.camera
  /// Returns picked file or null if canceled/errored
  Future<XFile?> pickImage(ImageSource source) async {
    isImageLoading.value = true;
    try {
      final pickedFile = await ImagePicker().pickImage(
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
      _showError('Failed to pick image', e);
    } finally {
      isImageLoading.value = false;
    }
    return null;
  }

  // ==============================
  // DateTime Pickers
  // ==============================

  /// Shows time picker dialog and updates selectedTime
  Future<void> selectTime(BuildContext context) async {
    final picked = await showTimePicker(
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

  /// Shows date picker dialog and updates start/end date
  ///
  /// [isStartDate]: True when selecting start date, false for end date
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

  // ==============================
  // Routine CRUD Operations
  // ==============================

  /// Saves new routine to Firestore and updates local state
  ///
  /// 1. Creates routine ID
  /// 2. Saves icon image locally
  /// 3. Creates CustomRoutine object
  /// 4. Persists to Firestore
  /// 5. Updates local routines list
  /// 6. Schedules notifications
  Future<void> saveRoutine() async {
    try {
      final newRoutine = await _createRoutine();
      await _saveRoutineToFirestore(newRoutine);

      routines.add(newRoutine);
      await _notificationService.scheduleCustomRoutines();
      _showSuccess('Routine created successfully!');
      _resetFormAndNavigate();
    } catch (e) {
      _showError('Failed to save routine', e);
    }
  }

  /// Creates CustomRoutine instance with current form values
  Future<CustomRoutine> _createRoutine() async {
    final routineId = _uuid.v4();
    final iconPath = await _saveLocalIcon(routineId);

    return CustomRoutine(
      id: routineId,
      name: nameController.text.trim(),
      description: descController.text.trim(),
      time: selectedTime.value,
      userId: _userId,
      createdDate: DateTime.now(),
      localIconPath: iconPath ?? '',
      startDate: startDate.value,
      endDate: endDate.value,
      isCompleted: false,
      completionProgress: 0.0,
      completionDates: [],
      imagePath: '',
    );
  }

  /// Saves routine to Firestore under user's routines collection
  Future<void> _saveRoutineToFirestore(CustomRoutine routine) async {
    await _userRoutines.doc(routine.id).set(routine.toMap());
  }

  /// Fetches all routines for current user from Firestore
  Future<void> fetchRoutines() async {
    try {
      isLoading.value = true;
      final snapshot = await _userRoutines.orderBy('createdDate').get();

      routines.assignAll(snapshot.docs
          .map((d) => CustomRoutine.fromMap(d.data() as Map<String, dynamic>)));
      _filterRoutines();
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggles completion status for routine on selected date
  ///
  /// [routineId]: ID of routine to toggle
  Future<void> toggleRoutineCompletion(String routineId) async {
    try {
      final index = routines.indexWhere((r) => r.id == routineId);
      if (index == -1) return;

      final updated = routines[index].toggleCompletion(selectedDate.value);
      await _userRoutines.doc(routineId).update(updated.toMap());

      routines[index] = updated;
      _filterRoutines();
    } catch (e) {
      _showError('Failed to toggle completion', e);
    }
  }

  /// Deletes routine from Firestore and local state
  ///
  /// [id]: ID of routine to delete
  Future<void> deleteRoutine(String id) async {
    try {
      final routine = routines.firstWhere((r) => r.id == id);
      await _userRoutines.doc(id).delete();
      await _notificationService.cancelRoutineNotifications(routine);

      routines.removeWhere((r) => r.id == id);
      _filterRoutines();
    } catch (e) {
      _showError('Failed to delete routine', e);
    }
  }

  // ==============================
  // Helpers & Utilities
  // ==============================

  /// Saves routine icon to local storage
  ///
  /// [routineId]: ID used for filename
  /// Returns file path if successful, null otherwise
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
      _showError('Failed to save icon', e);
      return null;
    }
  }

  /// Filters routines based on currently selected date
  ///
  /// Includes routines where:
  /// - No end date: Matches start date exactly
  /// - With end date: Falls within [startDate, endDate] range
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
          ? DateUtils.isSameDay(start, selected)
          : selected.isAfter(start.subtract(const Duration(days: 1))) &&
              selected.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Checks if routine was completed on selected date
  bool isDateCompleted(CustomRoutine routine) {
    return routine.completionDates
        .any((d) => DateUtils.isSameDay(d, selectedDate.value));
  }

  /// Count of completed routines on selected date
  int get completedCount =>
      filteredRoutines.where((r) => isDateCompleted(r)).length;

  /// Resets form state and navigates to home screen
  void _resetFormAndNavigate() {
    nameController.clear();
    descController.clear();
    selectedTime.value = TimeOfDay.now();
    localIcon.value = null;
    startDate.value = DateTime.now();
    endDate.value = null;
    Get.off(() => const LayoutScreen());
  }

  // ==============================
  // UI Feedback
  // ==============================

  /// Shows success snackbar
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

  /// Shows error snackbar with details
  void _showError(String title, dynamic e) {
    showCustomSnackbar('Error: $title', e.toString());
  }
}

/// Date comparison utilities
class DateUtils {
  /// Checks if two dates represent the same calendar day
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
