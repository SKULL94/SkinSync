import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/auth/auth_controller.dart';
import 'package:skin_sync/modules/auth/widgets/auth_screen_widget.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final AuthController controller = Get.find();

  @override
  Widget build(BuildContext context) {
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
                      child: AuthScreenBuildPhoneInput(
                        controller: controller,
                        theme: theme,
                        isTabletDevice: isTabletDevice,
                      ),
                    ),
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
                                // ButtonSegment(
                                //   value: false,
                                //   label: Text("New User"),
                                // ),
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
                              color: theme.colorScheme.surfaceContainerHighest,
                              fontSize: getResponsiveFontSize(context, 16),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: getHeight(context, 40)),
                  SizedBox(height: getHeight(context, 24)),
                  AuthScreenBuildPhoneInput(
                    controller: controller,
                    theme: theme,
                    isTabletDevice: isTabletDevice,
                  ),
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
}
