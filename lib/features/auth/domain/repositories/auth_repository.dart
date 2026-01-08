import 'package:dartz/dartz.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> sendOtp(String phoneNumber);
  Future<Either<Failure, UserEntity>> verifyOtp({
    required String verificationId,
    required String smsCode,
  });
  Future<Either<Failure, UserEntity>> signInWithCredential(
    dynamic credential,
  );
  Future<Either<Failure, void>> signOut();
  UserEntity? getCurrentUser();
}
