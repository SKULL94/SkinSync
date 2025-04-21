import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/routes/app_routes.dart';
import 'package:skin_sync/utils/app_utils.dart';
import 'package:skin_sync/utils/storage.dart';

class AuthController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxBool isLogin = true.obs;
  final RxBool showPhoneAuth = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isOtpSent = false.obs;
  final RxString verificationId = ''.obs;
  RxString phoneNumber = ''.obs;
  final RxBool useEmailMethod = true.obs;

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void toggleAuthType(bool isLoginValue) => isLogin.value = isLoginValue;

  void toggleAuthMethod() {
    useEmailMethod.value = !useEmailMethod.value;
  }

  Future<void> handleAuth() async {
    if (useEmailMethod.value) {
      await handleEmailAuth();
    } else {
      await handlePhoneAuth();
    }
  }

  Future<void> handlePhoneAuth() async {
    if (isOtpSent.value) {
      await verifyOtp();
    } else {
      await verifyPhoneNumber();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading(true);
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await auth.signInWithCredential(credential);
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _handleNewUserSetup(userCredential.user!.uid);
      }

      await handleSuccessfulAuth(userCredential.user!.uid);
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign in with Google: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> handleEmailAuth() async {
    if (!validateEmailPassword()) return;

    isLoading(true);
    try {
      if (isLogin.value) {
        await signInWithEmailPassword();
      } else {
        await createUserWithEmailPassword();
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> verifyPhoneNumber() async {
    if (phoneNumber.value.isEmpty) {
      Get.snackbar('Error', 'Please enter a valid phone number');
      return;
    }
    isLoading(true);
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.value,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          await auth.signInWithCredential(credential);
          await handleSuccessfulAuth(auth.currentUser!.uid);
        },
        verificationFailed: (e) {
          Get.snackbar('Error', 'Verification failed: ${e.message}');
        },
        codeSent: (verificationId, [forceResendingToken]) {
          this.verificationId.value = verificationId;
          isOtpSent(true);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          this.verificationId.value = verificationId;
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to verify phone number: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> verifyOtp() async {
    isLoading(true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otpController.text,
      );
      final userCredential = await auth.signInWithCredential(credential);
      await handleSuccessfulAuth(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', 'Invalid OTP: ${e.message}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> signInWithEmailPassword() async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await handleSuccessfulAuth(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', _mapAuthError(e));
    }
  }

  Future<void> createUserWithEmailPassword() async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await _handleNewUserSetup(userCredential.user!.uid);
      await handleSuccessfulAuth(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', _mapAuthError(e));
    }
  }

  Future<void> sendPasswordResetEmail() async {
    try {
      await auth.sendPasswordResetEmail(email: emailController.text.trim());
      Get.snackbar('Success', 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', 'Failed to send email: ${e.message}');
    }
  }

  Future<void> handleSuccessfulAuth(String userId) async {
    StorageService.instance.save(AppUtils.userId, userId);
    Get.snackbar('Success', 'Authentication successful');
    await checkExistingRoutines(userId);
  }

  Future<void> _handleNewUserSetup(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      await _firestore.collection('users').doc(userId).set({
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'streakCount': 0,
        'lastUpdatedDay': DateTime.now().toString().split(' ')[0],
      });
    }
  }

  bool validateEmailPassword() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return false;
    }
    if (!isLogin.value &&
        passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match');
      return false;
    }
    return true;
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password is too weak';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  Future<void> checkExistingRoutines(String userId) async {
    try {
      Get.put(RoutineController());
      final routineController = Get.find<RoutineController>();
      await routineController.fetchRoutines();
      Get.offAllNamed(AppRoutes.layoutRoute);
    } catch (e) {
      Get.offAllNamed(AppRoutes.layoutRoute);
    }
  }
}
