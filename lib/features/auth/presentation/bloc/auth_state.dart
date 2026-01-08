part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  loading,
  otpSent,
  authenticated,
  failure,
}

final class AuthState extends Equatable {
  final AuthStatus status;
  final String phoneNumber;
  final String otp;
  final String verificationId;
  final bool isLogin;
  final String? userId;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.phoneNumber = '',
    this.otp = '',
    this.verificationId = '',
    this.isLogin = true,
    this.userId,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? phoneNumber,
    String? otp,
    String? verificationId,
    bool? isLogin,
    String? userId,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otp: otp ?? this.otp,
      verificationId: verificationId ?? this.verificationId,
      isLogin: isLogin ?? this.isLogin,
      userId: userId ?? this.userId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        phoneNumber,
        otp,
        verificationId,
        isLogin,
        userId,
        errorMessage,
      ];
}
