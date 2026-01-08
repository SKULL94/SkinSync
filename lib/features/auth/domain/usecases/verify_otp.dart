import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/usecases/usecase.dart';
import 'package:skin_sync/features/auth/domain/entities/user_entity.dart';
import 'package:skin_sync/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtp implements UseCase<UserEntity, VerifyOtpParams> {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(VerifyOtpParams params) {
    return repository.verifyOtp(
      verificationId: params.verificationId,
      smsCode: params.smsCode,
    );
  }
}

class VerifyOtpParams extends Equatable {
  final String verificationId;
  final String smsCode;

  const VerifyOtpParams({
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object?> get props => [verificationId, smsCode];
}
