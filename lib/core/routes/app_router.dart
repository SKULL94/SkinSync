import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:skin_sync/features/history/presentation/pages/history_page.dart';
import 'package:skin_sync/features/layout/presentation/pages/layout_page.dart';
import 'package:skin_sync/features/home-screen/presentation/pages/create_routine_page.dart';
import 'package:skin_sync/features/home-screen/presentation/pages/routine_page.dart';
import 'package:skin_sync/features/skin_analysis/presentation/pages/skin_analysis_page.dart';
import 'package:skin_sync/features/splash/presentation/pages/splash_page.dart';
import 'package:skin_sync/features/streaks/presentation/pages/streaks_page.dart';
import 'package:skin_sync/features/auth/presentation/pages/auth_page.dart';
import 'package:skin_sync/core/routes/app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splashScreen,
  observers: [GoRouterObserver(), defaultLifecycleObserver],
  routes: [
    GoRoute(
      path: AppRoutes.splashScreen,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.authRoute,
      name: 'auth',
      builder: (context, state) => const AuthPage(),
    ),
    GoRoute(
      path: AppRoutes.createRoutineRoute,
      name: 'createRoutine',
      builder: (context, state) => const CreateRoutinePage(),
    ),
    GoRoute(
      path: AppRoutes.layoutRoute,
      name: 'layout',
      builder: (context, state) => const LayoutPage(),
    ),
    GoRoute(
      path: AppRoutes.routineRoute,
      name: 'routine',
      builder: (context, state) => const RoutinePage(),
    ),
    GoRoute(
      path: AppRoutes.streaksRoute,
      name: 'streaks',
      builder: (context, state) => const StreaksPage(),
    ),
    GoRoute(
      path: AppRoutes.skinAnalysisRoute,
      name: 'skinAnalysis',
      builder: (context, state) => const SkinAnalysisPage(),
    ),
    GoRoute(
      path: AppRoutes.historyRoute,
      name: 'history',
      builder: (context, state) => const HistoryPage(),
    ),
  ],
);

// MARK: - Observing Navigation Stack
class GoRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint(
      'Pushed: ${route.settings.name}, with arguments: ${route.settings.arguments}',
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint(
      'Popped: ${route.settings.name}, with arguments: ${route.settings.arguments}',
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint(
      'Removed: ${route.settings.name}, with arguments: ${route.settings.arguments}',
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    debugPrint(
      'Replaced: ${newRoute?.settings.name}, with arguments: ${newRoute?.settings.arguments}',
    );
  }
}
