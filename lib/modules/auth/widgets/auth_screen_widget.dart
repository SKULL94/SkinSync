import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pinput/pinput.dart';
import 'package:skin_sync/modules/auth/auth_controller.dart';
import 'package:skin_sync/utils/mediaquery.dart';

class AuthScreenBuildPhoneInput extends StatelessWidget {
  final AuthController controller;
  final ThemeData theme;
  final bool isTabletDevice;

  const AuthScreenBuildPhoneInput(
      {super.key,
      required this.isTabletDevice,
      required this.controller,
      required this.theme});
  @override
  Widget build(BuildContext context) {
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
              invalidNumberMessage: null),
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
}
