import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skin_sync/core/error/exceptions.dart';
import 'package:skin_sync/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<String> sendOtp(String phoneNumber);
  Future<UserModel> verifyOtp({
    required String verificationId,
    required String smsCode,
  });
  Future<UserModel> signInWithCredential(AuthCredential credential);
  Future<void> signOut();
  UserModel? getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<String> sendOtp(String phoneNumber) async {
    final completer = Completer<String>();

    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final userCredential =
              await firebaseAuth.signInWithCredential(credential);
          if (!completer.isCompleted && userCredential.user != null) {
            completer.complete(credential.verificationId ?? '');
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(
              AuthException(message: 'Auto verification failed: $e'),
            );
          }
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(
            AuthException(
              message: e.message ?? 'Verification failed',
              code: e.code,
            ),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
    );

    return completer.future;
  }

  @override
  Future<UserModel> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: e.message ?? 'OTP verification failed',
        code: e.code,
      );
    }
  }

  @override
  Future<UserModel> signInWithCredential(AuthCredential credential) async {
    try {
      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      if (userCredential.user == null) {
        throw const AuthException(message: 'Sign in failed: No user returned');
      }
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: e.message ?? 'Sign in failed',
        code: e.code,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: e.message ?? 'Sign out failed',
        code: e.code,
      );
    }
  }

  @override
  UserModel? getCurrentUser() {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }
}
