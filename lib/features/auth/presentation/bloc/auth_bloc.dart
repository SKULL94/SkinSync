import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skin_sync/core/constants/app_constants.dart';
import 'package:skin_sync/core/services/storage_service.dart';
import 'package:skin_sync/features/auth/domain/usecases/send_otp.dart';
import 'package:skin_sync/features/auth/domain/usecases/verify_otp.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtp sendOtp;
  final VerifyOtp verifyOtp;
  final StorageService storageService;

  AuthBloc({
    required this.sendOtp,
    required this.verifyOtp,
    required this.storageService,
  }) : super(const AuthState()) {
    on<AuthPhoneNumberChanged>(_onPhoneNumberChanged);
    on<AuthSendOtpRequested>(_onSendOtpRequested);
    on<AuthOtpChanged>(_onOtpChanged);
    on<AuthVerifyOtpRequested>(_onVerifyOtpRequested);
    on<AuthToggleAuthType>(_onToggleAuthType);
    on<AuthResetState>(_onResetState);
  }

  void _onPhoneNumberChanged(
    AuthPhoneNumberChanged event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(phoneNumber: event.phoneNumber));
  }

  Future<void> _onSendOtpRequested(
    AuthSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.phoneNumber.isEmpty) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Please enter a valid phone number',
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    final result = await sendOtp(SendOtpParams(phoneNumber: state.phoneNumber));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: failure.message,
      )),
      (verificationId) => emit(state.copyWith(
        status: AuthStatus.otpSent,
        verificationId: verificationId,
      )),
    );
  }

  void _onOtpChanged(
    AuthOtpChanged event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(otp: event.otp));
  }

  Future<void> _onVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.otp.isEmpty || state.otp.length < 6) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Please enter a valid OTP',
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    final result = await verifyOtp(VerifyOtpParams(
      verificationId: state.verificationId,
      smsCode: state.otp,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: failure.message,
      )),
      (user) {
        storageService.save(AppConstants.userId, user.uid);
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          userId: user.uid,
        ));
      },
    );
  }

  void _onToggleAuthType(
    AuthToggleAuthType event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(isLogin: event.isLogin));
  }

  void _onResetState(
    AuthResetState event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthState());
  }
}
