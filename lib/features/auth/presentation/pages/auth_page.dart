import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/utils/snackbar_helper.dart';
import 'package:skin_sync/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:skin_sync/features/auth/presentation/widgets/auth_phone_input.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:skin_sync/core/utils/mediaquery.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isTabletDevice = isTablet(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              previous.status != current.status,
          listener: (context, state) {
            if (state.status == AuthStatus.failure &&
                state.errorMessage != null) {
              SnackbarHelper.showError(context, state.errorMessage!);
            }
            if (state.status == AuthStatus.authenticated) {
              context.go(AppRoutes.layoutRoute);
            }
          },
          builder: (context, state) {
            if (state.status == AuthStatus.loading) {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: getWidth(context, 4),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(getWidth(context, 24)),
              child: _buildContent(
                context,
                state,
                theme,
                isTabletDevice,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AuthState state,
    ThemeData theme,
    bool isTabletDevice,
  ) {
    if (state.status == AuthStatus.otpSent) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: AuthPhoneInput(
                theme: theme,
                isTabletDevice: isTabletDevice,
                showOtpInput: true,
              ),
            ),
            SizedBox(height: getHeight(context, 20)),
            _buildSubmitButton(context, state, theme),
          ],
        ),
      );
    }

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, state, theme, isTabletDevice),
          SizedBox(height: getHeight(context, 40)),
          SizedBox(height: getHeight(context, 24)),
          AuthPhoneInput(
            theme: theme,
            isTabletDevice: isTabletDevice,
            showOtpInput: false,
          ),
          SizedBox(height: getHeight(context, 24)),
          _buildSubmitButton(context, state, theme),
          SizedBox(height: getHeight(context, 16)),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AuthState state,
    ThemeData theme,
    bool isTabletDevice,
  ) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.face,
            size: getWidth(context, 72),
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: getHeight(context, 24)),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTabletDevice ? 500 : double.infinity,
            ),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text(StringConst.kExistingUser),
                ),
              ],
              selected: {state.isLogin},
              onSelectionChanged: (Set<bool> newSelection) {
                context.read<AuthBloc>().add(
                      AuthToggleAuthType(newSelection.first),
                    );
              },
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(
                    vertical: getHeight(context, 12),
                    horizontal: getHeight(context, 12),
                  ),
                ),
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
            ),
          ),
          SizedBox(height: getHeight(context, 24)),
          Text(
            state.isLogin ? StringConst.kWelcomeBack : StringConst.kCreateAccount,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              fontSize: getResponsiveFontSize(context, 24),
            ),
          ),
          SizedBox(height: getHeight(context, 12)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getWidth(context, isTabletDevice ? 40 : 20),
            ),
            child: Text(
              state.isLogin
                  ? StringConst.kSignInToContinue
                  : StringConst.kStartYourRoutine,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.surfaceContainerHighest,
                fontSize: getResponsiveFontSize(context, 16),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    AuthState state,
    ThemeData theme,
  ) {
    return FilledButton(
      onPressed: () {
        if (state.status == AuthStatus.otpSent) {
          context.read<AuthBloc>().add(const AuthVerifyOtpRequested());
        } else {
          context.read<AuthBloc>().add(const AuthSendOtpRequested());
        }
      },
      style: FilledButton.styleFrom(
        minimumSize: Size(double.infinity, getHeight(context, 50)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(getWidth(context, 12)),
        ),
      ),
      child: Text(
        state.isLogin ? StringConst.kContinue : StringConst.kCreateAccount,
        style: TextStyle(
          fontSize: getResponsiveFontSize(context, 16),
        ),
      ),
    );
  }
}
