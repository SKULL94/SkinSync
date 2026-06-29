import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/constants/string_const.dart';
import 'package:skin_sync/core/di/injection_container.dart';
import 'package:skin_sync/core/routes/app_routes.dart';
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
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (p, c) =>
          p.status != c.status &&
          c.status == ProfileStatus.loading &&
          p.status == ProfileStatus.loaded,
      listener: (context, state) {
        if (state.status == ProfileStatus.loading && state.profile == null) {
          context.go(AppRoutes.splashScreen);
        }
      },
      buildWhen: (p, c) =>
          p.status != c.status || p.profile != c.profile,
      builder: (context, state) {
        if (state.status == ProfileStatus.initial ||
            (state.status == ProfileStatus.loading &&
                state.profile == null)) {
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

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: Column(
              children: [
                ProfileHero(
                  userName: state.userName,
                  memberSince: state.memberSince,
                ),
                const StatsStrip(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeader(StringConst.kSkinProfile),
                      const SizedBox(height: 12),
                      SkinTypeCard(
                        selectedType: state.skinType,
                        onTypeChanged: (type) => context
                            .read<ProfileBloc>()
                            .add(ProfileSkinTypeChanged(type)),
                      ),
                      const SizedBox(height: 12),
                      ConcernsCard(
                        selectedConcerns: state.concerns,
                        onConcernsChanged: (concerns) => context
                            .read<ProfileBloc>()
                            .add(ProfileConcernsChanged(concerns)),
                      ),
                      const SizedBox(height: 24),
                      const _SectionHeader(StringConst.kSettings),
                      const SizedBox(height: 12),
                      const SettingsCard(),
                      const SizedBox(height: 24),
                      SignOutButton(
                        onTap: () => _showSignOutDialog(context),
                      ),
                      SizedBox(
                        height: 100 + MediaQuery.of(context).padding.bottom,
                      ),
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

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          StringConst.kSignOut,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              StringConst.kCancel,
              style: GoogleFonts.hankenGrotesk(
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<ProfileBloc>()
                  .add(const ProfileSignOutRequested());
              context.go(AppRoutes.splashScreen);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.alert,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              StringConst.kSignOut,
              style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        letterSpacing: -0.17,
      ),
    );
  }
}
