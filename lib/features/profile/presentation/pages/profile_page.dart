import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/di/injection_container.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
import 'package:skin_sync/core/theme/theme_extension.dart';
import 'package:skin_sync/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:skin_sync/features/profile/presentation/widgets/concerns_card.dart';
import 'package:skin_sync/features/profile/presentation/widgets/profile_hero.dart';
import 'package:skin_sync/features/profile/presentation/widgets/settings_card.dart';
import 'package:skin_sync/features/profile/presentation/widgets/sign_out_button.dart';
import 'package:skin_sync/features/profile/presentation/widgets/skin_type_card.dart';
import 'package:skin_sync/features/profile/presentation/widgets/stats_strip.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(const ProfileLoadRequested()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == ProfileStatus.loading &&
          previous.status == ProfileStatus.loaded,
      listener: (context, state) {
        // Handle sign out navigation
        if (state.status == ProfileStatus.loading && state.profile == null) {
          context.go(AppRoutes.splashScreen);
        }
      },
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.profile != current.profile,
      builder: (context, state) {
        if (state.status == ProfileStatus.initial ||
            state.status == ProfileStatus.loading && state.profile == null) {
          return Scaffold(
            backgroundColor: colors.background,
            body: Center(
              child: CircularProgressIndicator(color: colors.primary),
            ),
          );
        }

        return Scaffold(
          backgroundColor: colors.background,
          body: SingleChildScrollView(
            child: Column(
              children: [
                ProfileHero(
                  userName: state.userName,
                  memberSince: state.memberSince,
                ),
                const StatsStrip(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      SkinTypeCard(
                        selectedType: state.skinType,
                        onTypeChanged: (type) => context
                            .read<ProfileBloc>()
                            .add(ProfileSkinTypeChanged(type)),
                      ),
                      const SizedBox(height: 16),
                      ConcernsCard(
                        selectedConcerns: state.concerns,
                        onConcernsChanged: (concerns) => context
                            .read<ProfileBloc>()
                            .add(ProfileConcernsChanged(concerns)),
                      ),
                      const SizedBox(height: 16),
                      const SettingsCard(),
                      const SizedBox(height: 24),
                      SignOutButton(
                        onTap: () => _showSignOutConfirmation(context),
                      ),
                      const SizedBox(height: 108),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSignOutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProfileBloc>().add(const ProfileSignOutRequested());
              context.go(AppRoutes.splashScreen);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.rose),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
