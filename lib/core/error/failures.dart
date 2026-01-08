import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred', super.code});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred', super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection',
    super.code,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failed', super.code});
}

class FirebaseFailure extends Failure {
  const FirebaseFailure({super.message = 'Firebase error occurred', super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure({super.message = 'Validation failed', super.code});
}

class PermissionFailure extends Failure {
  const PermissionFailure({super.message = 'Permission denied', super.code});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unknown error occurred', super.code});
}
