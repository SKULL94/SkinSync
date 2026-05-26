import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/utils/snackbar_helper.dart';
import 'package:skin_sync/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:skin_sync/core/routes/app_routes.dart';

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
          // Existing user with profile - go directly to home
          context.go(AppRoutes.layoutRoute);
        }
        if (state.status == AuthStatus.authenticatedNoProfile) {
          // New user or user without profile
          if (state.isLogin) {
            // User tried to sign in but doesn't have profile
            SnackbarHelper.showInfo(
              context,
              'Welcome! Please complete your profile setup.',
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
  final String _countryCode = '+91';
  bool _isValidPhone = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final isValid = digits.length == 10;
    if (isValid != _isValidPhone) {
      setState(() => _isValidPhone = isValid);
    }
  }

  void _onSendOtp() {
    if (!_isValidPhone) return;
    final phone = '$_countryCode${_phoneController.text.replaceAll(' ', '')}';
    context.read<AuthBloc>().add(AuthPhoneNumberChanged(phone));
    context.read<AuthBloc>().add(const AuthSendOtpRequested());
  }

  @override
  Widget build(BuildContext context) {
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
                          color: const Color(0xFFE0D8CC),
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

                    // Heading
                    Text(
                      'Your mobile\nnumber',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                        color: AppColors.ink,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Subheading
                    Text(
                      "We'll send a one-time code to verify",
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xFFA89880),
                        height: 1.7,
                      ),
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
                    // Label
                    Text(
                      'MOBILE NUMBER',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFA89880),
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Phone input field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE0D8CC),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Country code prefix
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            height: 52,
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Color(0xFFE0D8CC),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🇮🇳', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  _countryCode,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF7A6A5A),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Phone number input
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                color: AppColors.ink,
                              ),
                              decoration: InputDecoration(
                                hintText: '98765 43210',
                                hintStyle: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: const Color(0xFFA89880),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Send OTP button
                    GestureDetector(
                      onTap: _isValidPhone ? _onSendOtp : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _isValidPhone
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: _isValidPhone
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.28),
                                    blurRadius: 24,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Send OTP →',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _isValidPhone
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Terms and privacy
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: const Color(0xFFA89880),
                            height: 1.8,
                          ),
                          children: [
                            const TextSpan(text: 'By continuing you agree to our '),
                            TextSpan(
                              text: 'Terms',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: const Color(0xFFC06E44),
                              ),
                            ),
                            const TextSpan(text: ' & '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: const Color(0xFFC06E44),
                              ),
                            ),
                          ],
                        ),
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
    final phoneNumber = context.watch<AuthBloc>().state.phoneNumber;

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
                          color: const Color(0xFFE0D8CC),
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

                    // Heading
                    Text(
                      'Enter the\n6-digit code',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                        color: AppColors.ink,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Subheading
                    Text(
                      'Sent to your number',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xFFA89880),
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),

              // Phone number display
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAE3D9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    phoneNumber,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4A3B2E),
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
                            child: _OtpInputBox(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              onChanged: (value) => _onOtpChanged(index, value),
                              onBackspace: () {
                                if (index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                              },
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
                          "Didn't receive it?",
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: const Color(0xFFA89880),
                          ),
                        ),
                        GestureDetector(
                          onTap: _onResend,
                          child: Text(
                            ' Resend',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFC06E44),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Verify button
                    GestureDetector(
                      onTap: _onVerify,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.28),
                              blurRadius: 24,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Verify & Continue →',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Progress dots
                    const _ProgressDots(currentStep: 1, totalSteps: 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// OTP Input Box
class _OtpInputBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpInputBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFE0D8CC),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// Progress dots indicator
class _ProgressDots extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _ProgressDots({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isDone = index < currentStep;
        final isCurrent = index == currentStep;

        return Container(
          width: isDone ? 32 : 24,
          height: 3,
          margin: EdgeInsets.only(left: index == 0 ? 0 : 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: isDone || isCurrent
                ? AppColors.primary
                : const Color(0xFFE0D8CC),
          ),
        );
      }),
    );
  }
}
