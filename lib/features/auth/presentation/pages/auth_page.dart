import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/constants/text_styles.dart';
import 'package:skin_sync/core/utils/snackbar_helper.dart';
import 'package:skin_sync/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:skin_sync/features/auth/presentation/widgets/otp_input_box.dart';
import 'package:skin_sync/features/auth/presentation/widgets/primary_button.dart';
import 'package:skin_sync/features/auth/presentation/widgets/progress_indicator.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.failure && state.errorMessage != null) {
          SnackbarHelper.showError(context, state.errorMessage!);
        }
        if (state.status == AuthStatus.authenticatedWithProfile) {
          context.go(AppRoutes.layoutRoute);
        }
        if (state.status == AuthStatus.authenticatedNoProfile) {
          if (state.isLogin) {
            SnackbarHelper.showInfo(
              context,
              StringConst.kWelcomeCompleteProfile,
            );
          }
          context.go(AppRoutes.onboardingRoute);
        }
      },
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        if (state.status == AuthStatus.loading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        }

        if (state.status == AuthStatus.otpSent) {
          return const _OtpVerificationView();
        }

        return const _PhoneInputView();
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PHONE INPUT VIEW
// ═══════════════════════════════════════════════════════════════════════════

class _PhoneInputView extends StatefulWidget {
  const _PhoneInputView();

  @override
  State<_PhoneInputView> createState() => _PhoneInputViewState();
}

class _PhoneInputViewState extends State<_PhoneInputView> {
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  static const String _countryCode = '+91';

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onSendOtp() {
    final phone = '$_countryCode${_phoneController.text.replaceAll(' ', '')}';
    context.read<AuthBloc>().add(AuthPhoneNumberChanged(phone));
    context.read<AuthBloc>().add(const AuthSendOtpRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) =>
          previous.isPhoneValid != current.isPhoneValid ||
          previous.status != current.status,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 74, 28, 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge icon
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: AppColors.cardBorder,
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.phone_android,
                            size: 22,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          StringConst.kYourMobileNumber,
                          style: AppTextStyles.heading2.copyWith(fontSize: 30),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          StringConst.kWellSendCode,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // Body section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StringConst.kMobileNumber,
                          style: AppTextStyles.overline,
                        ),
                        const SizedBox(height: 10),

                        // Phone input field
                        TextField(
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          keyboardType: TextInputType.phone,
                          style: AppTextStyles.inputText,
                          onChanged: (value) {
                            final digits =
                                value.replaceAll(RegExp(r'\D'), '');
                            context.read<AuthBloc>().add(
                                  AuthPhoneValidationChanged(
                                      digits.length == 10),
                                );
                          },
                          decoration: InputDecoration(
                            hintText: StringConst.kPhoneHint,
                            hintStyle: AppTextStyles.inputHint,
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 16, right: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🇮🇳',
                                      style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(
                                    _countryCode,
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Send OTP button
                        PrimaryButton(
                          label: '${StringConst.kSendOtp} →',
                          enabled: state.isPhoneValid,
                          onTap: _onSendOtp,
                        ),

                        const SizedBox(height: 16),

                        // Terms and privacy
                        Center(
                          child: Text.rich(
                            TextSpan(
                              style:
                                  AppTextStyles.caption.copyWith(height: 1.8),
                              children: [
                                const TextSpan(text: StringConst.kTermsPrivacy),
                                TextSpan(
                                  text: StringConst.kTerms,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                const TextSpan(text: ' & '),
                                TextSpan(
                                  text: StringConst.kPrivacyPolicy,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// OTP VERIFICATION VIEW
// ═══════════════════════════════════════════════════════════════════════════

class _OtpVerificationView extends StatefulWidget {
  const _OtpVerificationView();

  @override
  State<_OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<_OtpVerificationView> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    final otp = _otpControllers.map((c) => c.text).join();
    context.read<AuthBloc>().add(AuthOtpChanged(otp));

    if (otp.length == 6) {
      _onVerify();
    }
  }

  void _onVerify() {
    context.read<AuthBloc>().add(const AuthVerifyOtpRequested());
  }

  void _onResend() {
    context.read<AuthBloc>().add(const AuthSendOtpRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) =>
          previous.phoneNumber != current.phoneNumber,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 74, 28, 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge icon
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: AppColors.cardBorder,
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.mail_outline,
                            size: 22,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          StringConst.kEnterCode,
                          style: AppTextStyles.heading2.copyWith(fontSize: 30),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          StringConst.kSentToNumber,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // Phone number display
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        state.phoneNumber,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Body section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                    child: Column(
                      children: [
                        // OTP input row
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(6, (index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: index == 0 ? 0 : 8,
                                ),
                                child: OtpInputBox(
                                  controller: _otpControllers[index],
                                  focusNode: _focusNodes[index],
                                  onChanged: (value) =>
                                      _onOtpChanged(index, value),
                                ),
                              );
                            }),
                          ),
                        ),

                        // Resend row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              StringConst.kDidntReceive,
                              style: AppTextStyles.caption,
                            ),
                            GestureDetector(
                              onTap: _onResend,
                              child: Text(
                                ' ${StringConst.kResend}',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Verify button
                        PrimaryButton(
                          label: '${StringConst.kVerifyContinue} →',
                          enabled: true,
                          onTap: _onVerify,
                        ),

                        const SizedBox(height: 20),

                        // Progress dots
                        const AuthProgressIndicator(
                            currentStep: 1, totalSteps: 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
