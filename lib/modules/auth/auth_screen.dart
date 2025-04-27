import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pinput/pinput.dart';
import 'package:skin_sync/modules/auth/auth_controller.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());
    final theme = Theme.of(context);
    final bool isTabletDevice = isTablet(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(getWidth(context, 24)),
          child: Obx(() {
            if (controller.isLoading.value) {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: getWidth(context, 4),
                  ),
                ),
              );
            }

            if (controller.isOtpSent.value) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: _buildPhoneInput(
                            controller, theme, context, isTabletDevice)),
                    SizedBox(height: getHeight(context, 20)),
                    FilledButton(
                      onPressed: controller.handleAuth,
                      style: FilledButton.styleFrom(
                        minimumSize:
                            Size(double.infinity, getHeight(context, 50)),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(getWidth(context, 12)),
                        ),
                      ),
                      child: Text(
                        controller.isLogin.value
                            ? 'Continue'
                            : 'Create Account',
                        style: TextStyle(
                          fontSize: getResponsiveFontSize(context, 16),
                        ),
                      ),
                    ),
                  ],
                ),
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
                            size: getWidth(context, 72),
                            color: theme.colorScheme.primary),
                        SizedBox(height: getHeight(context, 24)),
                        ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isTabletDevice ? 500 : double.infinity,
                            ),
                            child: SegmentedButton<bool>(
                              segments: const [
                                ButtonSegment(
                                  value: true,
                                  label: Text('Existing User'),
                                ),
                                ButtonSegment(
                                  value: false,
                                  label: Text("New User"),
                                ),
                              ],
                              selected: {controller.isLogin.value},
                              onSelectionChanged: (Set<bool> newSelection) {
                                controller.toggleAuthType(newSelection.first);
                              },
                              style: ButtonStyle(
                                padding: WidgetStateProperty.all(
                                  EdgeInsets.symmetric(
                                    vertical: getHeight(context, 12),
                                    horizontal: getHeight(context, 12),
                                  ),
                                ),
                                visualDensity:
                                    VisualDensity.adaptivePlatformDensity,
                              ),
                            )),
                        SizedBox(height: getHeight(context, 24)),
                        Text(
                          controller.isLogin.value
                              ? 'Welcome Back!'
                              : 'Create Account',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                            fontSize: getResponsiveFontSize(context, 24),
                          ),
                        ),
                        SizedBox(height: getHeight(context, 12)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                getWidth(context, isTabletDevice ? 40 : 20),
                          ),
                          child: Text(
                            controller.isLogin.value
                                ? 'Sign in to continue your skincare journey'
                                : 'Start your personalized skincare routine',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: getResponsiveFontSize(context, 16),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: getHeight(context, 40)),
                  // _buildSocialAuthButtons(
                  //     controller, theme, isTabletDevice, context),
                  // SizedBox(height: getHeight(context, 24)),
                  // Row(
                  //   children: [
                  //     Expanded(child: Divider(color: theme.dividerColor)),
                  //     Padding(
                  //       padding: EdgeInsets.symmetric(
                  //           horizontal: getWidth(context, 12)),
                  //       child: Text(
                  //         'or continue with',
                  //         style: TextStyle(
                  //           color: theme.colorScheme.onSurfaceVariant,
                  //           fontSize: getResponsiveFontSize(context, 14),
                  //         ),
                  //       ),
                  //     ),
                  //     Expanded(child: Divider(color: theme.dividerColor)),
                  //   ],
                  // ),
                  // SizedBox(height: getHeight(context, 24)),
                  // Center(
                  //   child: Obx(() {
                  //     final isEmailSelected = controller.useEmailMethod.value;
                  //     return Container(
                  //       decoration: BoxDecoration(
                  //         border: Border.all(
                  //           color: theme.dividerColor,
                  //           width: getWidth(context, 1),
                  //         ),
                  //         borderRadius:
                  //             BorderRadius.circular(getWidth(context, 12)),
                  //       ),
                  //       child: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           // InkWell(
                  //           //   onTap: () => controller.useEmailMethod(true),
                  //           //   child: Container(
                  //           //     decoration: BoxDecoration(
                  //           //       color: isEmailSelected
                  //           //           ? theme.colorScheme.primary
                  //           //               .withOpacity(0.1)
                  //           //           : Colors.transparent,
                  //           //       borderRadius: BorderRadius.only(
                  //           //         topLeft:
                  //           //             Radius.circular(getWidth(context, 12)),
                  //           //         bottomLeft:
                  //           //             Radius.circular(getWidth(context, 12)),
                  //           //       ),
                  //           //     ),
                  //           //     padding: EdgeInsets.symmetric(
                  //           //       horizontal: getWidth(context, 24),
                  //           //       vertical: getHeight(context, 14),
                  //           //     ),
                  //           //     child: Icon(
                  //           //       Icons.email,
                  //           //       size: getWidth(context, 24),
                  //           //       color: isEmailSelected
                  //           //           ? theme.colorScheme.primary
                  //           //           : theme.colorScheme.onSurfaceVariant,
                  //           //     ),
                  //           //   ),
                  //           // ),
                  //           // Container(
                  //           //   width: getWidth(context, 1),
                  //           //   height: getHeight(context, 40),
                  //           //   color: theme.dividerColor,
                  //           // ),
                  //           // InkWell(
                  //           //   onTap: () => controller.useEmailMethod(false),
                  //           //   child: Container(
                  //           //     decoration: BoxDecoration(
                  //           //       color: !isEmailSelected
                  //           //           ? theme.colorScheme.primary
                  //           //               .withOpacity(0.1)
                  //           //           : Colors.transparent,
                  //           //       borderRadius: BorderRadius.only(
                  //           //         topRight:
                  //           //             Radius.circular(getWidth(context, 12)),
                  //           //         bottomRight:
                  //           //             Radius.circular(getWidth(context, 12)),
                  //           //       ),
                  //           //     ),
                  //           //     padding: EdgeInsets.symmetric(
                  //           //       horizontal: getWidth(context, 24),
                  //           //       vertical: getHeight(context, 14),
                  //           //     ),
                  //           //     child: Icon(
                  //           //       Icons.phone,
                  //           //       size: getWidth(context, 24),
                  //           //       color: !isEmailSelected
                  //           //           ? theme.colorScheme.primary
                  //           //           : theme.colorScheme.onSurfaceVariant,
                  //           //     ),
                  //           //   ),
                  //           // ),
                  //         ],
                  //       ),
                  //     );
                  //   }),
                  // ),
                  SizedBox(height: getHeight(context, 24)),
                  controller.useEmailMethod.value
                      ? _buildPhoneInput(
                          controller, theme, context, isTabletDevice)
                      : _buildPhoneInput(
                          controller, theme, context, isTabletDevice),
                  SizedBox(height: getHeight(context, 24)),
                  FilledButton(
                    onPressed: controller.handleAuth,
                    style: FilledButton.styleFrom(
                      minimumSize:
                          Size(double.infinity, getHeight(context, 50)),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(getWidth(context, 12)),
                      ),
                    ),
                    child: Text(
                      controller.isLogin.value ? 'Continue' : 'Create Account',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(context, 16),
                      ),
                    ),
                  ),
                  SizedBox(height: getHeight(context, 16)),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // Widget _buildSocialAuthButtons(AuthController controller, ThemeData theme,
  //     bool isTablet, BuildContext context) {
  //   // MODIFIED
  //   return Column(
  //     children: [
  //       ConstrainedBox(
  //         constraints: BoxConstraints(
  //           maxWidth: isTablet ? 500 : double.infinity,
  //         ),
  //         child: OutlinedButton.icon(
  //           icon: Icon(Icons.g_mobiledata,
  //               size: getWidth(context, 24), color: Colors.red),
  //           label: Text('Continue with Google',
  //               style: TextStyle(fontSize: getResponsiveFontSize(context, 14))),
  //           onPressed: () => _handleGoogleSignIn(controller),
  //           style: OutlinedButton.styleFrom(
  //             minimumSize: Size(double.infinity, getHeight(context, 50)),
  //             padding: EdgeInsets.symmetric(vertical: getHeight(context, 14)),
  //           ),
  //         ),
  //       ),
  //       SizedBox(height: getHeight(context, 12)),
  //       ConstrainedBox(
  //         constraints: BoxConstraints(
  //           maxWidth: isTablet ? 500 : double.infinity,
  //         ),
  //         child: OutlinedButton.icon(
  //           icon: Icon(Icons.apple,
  //               size: getWidth(context, 24), color: Colors.black),
  //           label: Text('Continue with Apple',
  //               style: TextStyle(fontSize: getResponsiveFontSize(context, 14))),
  //           onPressed: () {},
  //           style: OutlinedButton.styleFrom(
  //             minimumSize: Size(double.infinity, getHeight(context, 50)),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Future<void> _handleGoogleSignIn(AuthController controller) async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     if (googleUser != null) {
  //       controller.isLoading(true);
  //       final GoogleSignInAuthentication googleAuth =
  //           await googleUser.authentication;
  //       final credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth.accessToken,
  //         idToken: googleAuth.idToken,
  //       );
  //       final UserCredential userCredential =
  //           await FirebaseAuth.instance.signInWithCredential(credential);
  //       await controller.handleSuccessfulAuth(userCredential.user!.uid);
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to sign in with Google: $e');
  //   } finally {
  //     controller.isLoading(false);
  //   }
  // }

  Widget _buildPhoneInput(AuthController controller, ThemeData theme,
      BuildContext context, bool isTabletDevice) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: getWidth(context, isTabletDevice ? 40 : 0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IntlPhoneField(
            controller: controller.phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone, size: getWidth(context, 24)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(getWidth(context, 12))),
              contentPadding: EdgeInsets.symmetric(
                vertical: getHeight(context, 16),
              ),
            ),
            initialCountryCode: 'IN',
            onChanged: (phone) =>
                controller.phoneNumber.value = phone.completeNumber,
          ),
          if (controller.isOtpSent.value) ...[
            SizedBox(height: getHeight(context, 20)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: getWidth(context, 20)),
              child: Text(
                'Enter verification code sent to ${controller.phoneNumber.value}',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontSize: getResponsiveFontSize(context, 14)),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: getHeight(context, 16)),
            Pinput(
              length: 6,
              controller: controller.otpController,
              defaultPinTheme: PinTheme(
                width: getWidth(context, 48),
                height: getHeight(context, 48),
                textStyle: theme.textTheme.titleLarge
                    ?.copyWith(fontSize: getResponsiveFontSize(context, 18)),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: theme.colorScheme.outline,
                      width: getWidth(context, 1)),
                  borderRadius: BorderRadius.circular(getWidth(context, 12)),
                ),
              ),
              focusedPinTheme: PinTheme(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: theme.colorScheme.primary,
                      width: getWidth(context, 2)),
                  borderRadius: BorderRadius.circular(getWidth(context, 12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Widget _buildEmailInput(AuthController controller, ThemeData theme,
  //     BuildContext context, bool isTabletDevice) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(
  //         horizontal: getWidth(context, isTabletDevice ? 40 : 0)),
  //     child: Column(
  //       children: [
  //         TextFormField(
  //           controller: controller.emailController,
  //           decoration: InputDecoration(
  //             labelText: 'Email',
  //             prefixIcon: Icon(Icons.email, size: getWidth(context, 24)),
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(getWidth(context, 12)),
  //             ),
  //             contentPadding: EdgeInsets.symmetric(
  //               vertical: getHeight(context, 16),
  //             ),
  //           ),
  //           style: TextStyle(fontSize: getResponsiveFontSize(context, 14)),
  //         ),
  //         SizedBox(height: getHeight(context, 20)),
  //         TextFormField(
  //           controller: controller.passwordController,
  //           obscureText: true,
  //           decoration: InputDecoration(
  //             labelText: 'Password',
  //             prefixIcon: Icon(Icons.lock, size: getWidth(context, 24)),
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(getWidth(context, 12)),
  //             ),
  //             contentPadding: EdgeInsets.symmetric(
  //               vertical: getHeight(context, 16),
  //             ),
  //           ),
  //           style: TextStyle(fontSize: getResponsiveFontSize(context, 14)),
  //         ),
  //         if (!controller.isLogin.value) ...[
  //           SizedBox(height: getHeight(context, 20)),
  //           TextFormField(
  //             controller: controller.confirmPasswordController,
  //             obscureText: true,
  //             decoration: InputDecoration(
  //               labelText: 'Confirm Password',
  //               prefixIcon: Icon(Icons.lock_reset, size: getWidth(context, 24)),
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(getWidth(context, 12)),
  //               ),
  //               contentPadding: EdgeInsets.symmetric(
  //                 vertical: getHeight(context, 16),
  //               ),
  //             ),
  //             style: TextStyle(fontSize: getResponsiveFontSize(context, 14)),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }
}
