import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skin_sync/modules/auth/auth_screen.dart';
import 'package:skin_sync/modules/auth/auth_binding.dart';
import 'package:skin_sync/modules/history/skin_analysis_binding.dart';
import 'package:skin_sync/modules/history/skin_analysis_history_screen.dart';
import 'package:skin_sync/modules/layout/layout_binding.dart';
import 'package:skin_sync/modules/layout/layout_screen.dart';
import 'package:skin_sync/modules/routine/custom_routine_screen.dart';
import 'package:skin_sync/modules/routine/routine_binding.dart';
import 'package:skin_sync/modules/routine/routine_screen.dart';
import 'package:skin_sync/modules/skin-analysis/skincare_analysis_binding.dart';
import 'package:skin_sync/modules/skin-analysis/skincare_analysis_screen.dart';
import 'package:skin_sync/modules/splash/app_splash_screen.dart';
import 'package:skin_sync/modules/streaks/streaks_binding.dart';
import 'package:skin_sync/modules/streaks/streaks_screen.dart';
import 'package:skin_sync/routes/app_routes.dart';

/// A helper function to initialize dependencies (previously bindings)
void initializeBindings(List<void Function()> bindings) {
  for (final binding in bindings) {
    binding();
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splashScreen,
  routes: [
    GoRoute(
      path: AppRoutes.splashScreen,
      name: 'splash',
      builder: (context, state) {
        // AuthBinding().dependencies();
        return AppSplashScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.authRoute,
      name: 'auth',
      builder: (context, state) {
        AuthBinding().dependencies();
        return AuthScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.streaksRoute,
      name: 'streaks',
      builder: (context, state) {
        StreaksBinding().dependencies();
        return StreaksScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.routineRoute,
      name: 'routine',
      builder: (context, state) {
        RoutineBinding().dependencies();
        return RoutineScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.layoutRoute,
      name: 'layout',
      builder: (context, state) {
        initializeBindings([
          () => SkinAnalysisBinding().dependencies(),
          () => SkincareAnalysisBinding().dependencies(),
          () => LayoutBinding().dependencies(),
          () => RoutineBinding().dependencies(),
          () => StreaksBinding().dependencies(),
        ]);
        return LayoutScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.createRoutineRoute,
      name: 'createRoutine',
      builder: (context, state) {
        RoutineBinding().dependencies();
        return CreateRoutineScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.skinAnalysisRoute,
      name: 'skinAnalysis',
      builder: (context, state) {
        SkincareAnalysisBinding().dependencies();
        return SkincareAnalysisScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.historyRoute,
      name: 'history',
      builder: (context, state) {
        SkinAnalysisBinding().dependencies();
        return const HistoryScreen();
      },
    ),
  ],
);
