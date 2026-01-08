part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthPhoneNumberChanged extends AuthEvent {
  final String phoneNumber;

  const AuthPhoneNumberChanged(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

final class AuthSendOtpRequested extends AuthEvent {
  const AuthSendOtpRequested();
}

final class AuthOtpChanged extends AuthEvent {
  final String otp;

  const AuthOtpChanged(this.otp);

  @override
  List<Object?> get props => [otp];
}

final class AuthVerifyOtpRequested extends AuthEvent {
  const AuthVerifyOtpRequested();
}

final class AuthToggleAuthType extends AuthEvent {
  final bool isLogin;

  const AuthToggleAuthType(this.isLogin);

  @override
  List<Object?> get props => [isLogin];
}

final class AuthResetState extends AuthEvent {
  const AuthResetState();
}
