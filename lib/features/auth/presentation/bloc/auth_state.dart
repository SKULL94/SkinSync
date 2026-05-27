part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  loading,
  otpSent,
  authenticated,
  authenticatedWithProfile,
  authenticatedNoProfile,
  failure,
}

final class AuthState extends Equatable {
  final AuthStatus status;
  final String phoneNumber;
  final String otp;
  final String verificationId;
  final bool isLogin;
  final bool isPhoneValid;
  final String? userId;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.phoneNumber = '',
    this.otp = '',
    this.verificationId = '',
    this.isLogin = true,
    this.isPhoneValid = false,
    this.userId,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? phoneNumber,
    String? otp,
    String? verificationId,
    bool? isLogin,
    bool? isPhoneValid,
    String? userId,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otp: otp ?? this.otp,
      verificationId: verificationId ?? this.verificationId,
      isLogin: isLogin ?? this.isLogin,
      isPhoneValid: isPhoneValid ?? this.isPhoneValid,
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
        isPhoneValid,
        userId,
        errorMessage,
      ];
}
