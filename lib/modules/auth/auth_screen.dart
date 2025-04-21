import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pinput/pinput.dart';
import 'package:skin_sync/modules/auth/auth_controller.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            if (controller.isLoading.value) {
              return SizedBox(
                height: size.height,
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            return AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.face,
                            size: 72, color: theme.colorScheme.primary),
                        const SizedBox(height: 24),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(
                              value: true,
                              label: Text('Already an existing user?'),
                            ),
                            ButtonSegment(
                              value: false,
                              label: Text("First Time?"),
                            ),
                          ],
                          selected: {controller.isLogin.value},
                          onSelectionChanged: (Set<bool> newSelection) {
                            controller.toggleAuthType(newSelection.first);
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
                                  return theme.colorScheme.primaryContainer;
                                }
                                return theme
                                    .colorScheme.surfaceContainerHighest;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          controller.isLogin.value
                              ? 'Welcome Back!'
                              : 'Create Account',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          controller.isLogin.value
                              ? 'Sign in to continue your skincare journey'
                              : 'Start your personalized skincare routine',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildSocialAuthButtons(controller, theme),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: Divider(color: theme.dividerColor)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or continue with',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: theme.dividerColor)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Obx(() {
                      final isEmailSelected = controller.useEmailMethod.value;
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => controller.useEmailMethod(true),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isEmailSelected
                                      ? theme.colorScheme.primary
                                          .withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                child: Icon(
                                  Icons.email,
                                  color: isEmailSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: theme.dividerColor,
                            ),
                            InkWell(
                              onTap: () => controller.useEmailMethod(false),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !isEmailSelected
                                      ? theme.colorScheme.primary
                                          .withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                child: Icon(
                                  Icons.phone,
                                  color: !isEmailSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),
                  controller.useEmailMethod.value
                      ? _buildEmailInput(controller, theme)
                      : _buildPhoneInput(controller, theme),

                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: controller.handleAuth,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      controller.isLogin.value ? 'Continue' : 'Create Account',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Alternative Auth Methods Text
                  // Center(
                  //   child: TextButton(
                  //     onPressed: controller.toggleAuthMethod,
                  //     child: RichText(
                  //       text: TextSpan(
                  //         style: theme.textTheme.bodyMedium?.copyWith(
                  //           color: theme.colorScheme.onSurfaceVariant,
                  //         ),
                  //         children: [
                  //           TextSpan(
                  //             text: controller.showPhoneAuth.value
                  //                 ? 'Use Email Instead'
                  //                 : 'Use Phone Instead',
                  //           ),
                  //           if (controller.isLogin.value) ...[
                  //             const TextSpan(text: '  •  '),
                  //             TextSpan(
                  //               text: 'Forgot Password?',
                  //               style: TextStyle(
                  //                 color: theme.colorScheme.primary,
                  //                 fontWeight: FontWeight.w600,
                  //               ),
                  //             ),
                  //           ],
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSocialAuthButtons(AuthController controller, ThemeData theme) {
    return Column(
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.g_mobiledata, size: 24, color: Colors.red),
          label: const Text('Continue with Google'),
          onPressed: () => _handleGoogleSignIn(controller),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.apple, size: 24, color: Colors.black),
          label: const Text('Continue with Apple'),
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Future<void> _handleGoogleSignIn(AuthController controller) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        controller.isLoading(true);
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        await controller.handleSuccessfulAuth(userCredential.user!.uid);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign in with Google: $e');
    } finally {
      controller.isLoading(false);
    }
  }

  Widget _buildPhoneInput(AuthController controller, ThemeData theme) {
    return Column(
      children: [
        IntlPhoneField(
          controller: controller.phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            prefixIcon:
                Icon(Icons.phone, color: theme.colorScheme.onSurfaceVariant),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          initialCountryCode: 'US',
          onChanged: (phone) =>
              controller.phoneNumber.value = phone.completeNumber,
        ),
        if (controller.isOtpSent.value) ...[
          const SizedBox(height: 20),
          Text(
            'Enter verification code sent to ${controller.phoneNumber.value}',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Pinput(
            length: 6,
            controller: controller.otpController,
            defaultPinTheme: PinTheme(
              width: 48,
              height: 48,
              textStyle: theme.textTheme.titleLarge,
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            focusedPinTheme: PinTheme(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmailInput(AuthController controller, ThemeData theme) {
    return Column(
      children: [
        TextFormField(
          controller: controller.emailController,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon:
                Icon(Icons.email, color: theme.colorScheme.onSurfaceVariant),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: controller.passwordController,
          obscureText: true,
          autofillHints: const [AutofillHints.password],
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon:
                Icon(Icons.lock, color: theme.colorScheme.onSurfaceVariant),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (!controller.isLogin.value) ...[
          const SizedBox(height: 20),
          TextFormField(
            controller: controller.confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock_reset,
                  color: theme.colorScheme.onSurfaceVariant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
