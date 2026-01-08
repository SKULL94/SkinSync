import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/usecases/usecase.dart';
import 'package:skin_sync/features/auth/domain/repositories/auth_repository.dart';

class SendOtp implements UseCase<String, SendOtpParams> {
  final AuthRepository repository;

  SendOtp(this.repository);

  @override
  Future<Either<Failure, String>> call(SendOtpParams params) {
    return repository.sendOtp(params.phoneNumber);
  }
}

class SendOtpParams extends Equatable {
  final String phoneNumber;

  const SendOtpParams({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}
