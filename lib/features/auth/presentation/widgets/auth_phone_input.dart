import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pinput/pinput.dart';
import 'package:skin_sync/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:skin_sync/core/utils/mediaquery.dart';

class AuthPhoneInput extends StatelessWidget {
  final ThemeData theme;
  final bool isTabletDevice;
  final bool showOtpInput;

  const AuthPhoneInput({
    super.key,
    required this.theme,
    required this.isTabletDevice,
    required this.showOtpInput,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getWidth(context, isTabletDevice ? 40 : 0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IntlPhoneField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone, size: getWidth(context, 24)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(getWidth(context, 12)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: getHeight(context, 16),
                  ),
                ),
                initialCountryCode: 'IN',
                onChanged: (phone) {
                  context.read<AuthBloc>().add(
                        AuthPhoneNumberChanged(phone.completeNumber),
                      );
                },
                invalidNumberMessage: null,
              ),
              if (showOtpInput) ...[
                SizedBox(height: getHeight(context, 20)),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: getWidth(context, 20)),
                  child: Text(
                    'Enter verification code sent to ${state.phoneNumber}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: getResponsiveFontSize(context, 14),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: getHeight(context, 16)),
                Pinput(
                  length: 6,
                  onChanged: (value) {
                    context.read<AuthBloc>().add(AuthOtpChanged(value));
                  },
                  onCompleted: (value) {
                    context.read<AuthBloc>().add(const AuthVerifyOtpRequested());
                  },
                  defaultPinTheme: PinTheme(
                    width: getWidth(context, 48),
                    height: getHeight(context, 48),
                    textStyle: theme.textTheme.titleLarge?.copyWith(
                      fontSize: getResponsiveFontSize(context, 18),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: getWidth(context, 1),
                      ),
                      borderRadius:
                          BorderRadius.circular(getWidth(context, 12)),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: getWidth(context, 48),
                    height: getHeight(context, 48),
                    textStyle: theme.textTheme.titleLarge?.copyWith(
                      fontSize: getResponsiveFontSize(context, 18),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: getWidth(context, 2),
                      ),
                      borderRadius:
                          BorderRadius.circular(getWidth(context, 12)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
