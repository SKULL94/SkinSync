import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/model/routine.dart';
import 'package:skin_sync/routes/app_routes.dart';
import 'package:skin_sync/utils/app_utils.dart';
import 'package:skin_sync/utils/storage.dart';

class AuthController extends GetxController {
  PhoneAuthCredential? confirmationResult;
  FirebaseAuth auth = FirebaseAuth.instance;

  final Rx<TextEditingController> _otpController =
      Rx(TextEditingController(text: ""));

  final Rx<TextEditingController> _mobileNumberController =
      Rx(TextEditingController());

  final RxBool _isOtpSent = RxBool(false);

  final RxBool _isLoading = RxBool(false);

  final RxString _verificationIdd = RxString("");

  final RxString _userPhoneNumber = RxString("");

  final Rx _authFormKey = Rx(GlobalKey<FormState>());

  GlobalKey<FormState> get authFormKey => _authFormKey.value;

  String get userPhoneNumber => _userPhoneNumber.value;

  String get verificationIdd => _verificationIdd.value;

  bool get isLoading => _isLoading.value;

  bool get isOtpSent => _isOtpSent.value;

  TextEditingController get mobileNumberController =>
      _mobileNumberController.value;

  TextEditingController get otpController => _otpController.value;

  @override
  void dispose() {
    otpController.dispose();
    mobileNumberController.dispose();
    super.dispose();
  }

  updateIsOtpSent(bool value) {
    _isOtpSent.value = value;
    update();
  }

  updateIsLoading(bool value) {
    _isLoading.value = value;
    update();
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    if (!authFormKey.currentState!.validate()) {
      return;
    }
    updateIsLoading(true);
    try {
      _userPhoneNumber.value = phoneNumber;
      await auth.verifyPhoneNumber(
        phoneNumber: "+91$phoneNumber",
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
          updateIsOtpSent(true);
        },
        verificationFailed: (FirebaseAuthException e) {},
        codeSent: (String verificationId, int? resendToken) async {
          _verificationIdd.value = verificationId;
          updateIsLoading(false);
          updateIsOtpSent(true);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationIdd.value = verificationId;
        },
      );
    } catch (e) {
      updateIsLoading(false);
      Get.snackbar("Error", "Failed to verify phone number: $e");
    }
  }

  Future<void> signInWithPhoneNumber(String smsCode) async {
    updateIsLoading(true);
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationIdd,
        smsCode: smsCode,
      );

      UserCredential userCredential =
          await auth.signInWithCredential(credential);
      String userId = userCredential.user!.uid;
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userSnapshot.exists) {
        List<RoutineItem> initialRoutines = List.generate(
            5,
            (index) => RoutineItem.createNew(
                  routineId: 'routine_${index + 1}',
                  completedDate: '',
                  isRoutineDone: false,
                  imagePath: '',
                ));

        Routine initialRoutine = Routine.createNew(
          userId: userId,
          streakCount: 0,
          lastUpdatedDay: DateTime.now().toString().split(' ')[0],
          completedRoutines: {},
          allRoutines: initialRoutines,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set(initialRoutine.toJson());
      }

      if (userCredential.user != null) {
        StorageService.instance.save(AppUtils.userId, userId);
        updateIsLoading(false);
        Get.snackbar("Success", "Successfully authenticated");
        Get.offAllNamed(AppRoutes.layoutRoute);
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == "invalid-verification-code") {
        Get.snackbar("Error", "Wrong OTP, please try again");
      }
    } catch (e) {
      updateIsLoading(false);
      Get.snackbar("Error", "Failed to sign in with phone number: $e");
    }
  }
}
