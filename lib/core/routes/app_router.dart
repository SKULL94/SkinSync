import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:skin_sync/features/history/presentation/pages/history_page.dart';
import 'package:skin_sync/features/layout/presentation/pages/layout_page.dart';
import 'package:skin_sync/features/auth/presentation/pages/onboarding_page.dart';
import 'package:skin_sync/features/skin_analysis/presentation/pages/skin_analysis_page.dart';
import 'package:skin_sync/splash_page.dart';
import 'package:skin_sync/features/auth/presentation/pages/welcome_page.dart';
import 'package:skin_sync/features/auth/presentation/pages/auth_page.dart';
import 'package:skin_sync/features/profile/presentation/pages/personal_details.dart';
import 'package:skin_sync/features/profile/presentation/pages/scan_reminders.dart';
import 'package:skin_sync/features/profile/presentation/pages/skin_type.dart';
import 'package:skin_sync/features/home/presentation/pages/ai_tips_page.dart';
import 'package:skin_sync/features/home/presentation/pages/trends_page.dart';
import 'package:skin_sync/features/home/presentation/pages/routine_page.dart';
import 'package:skin_sync/features/home/presentation/pages/skin_news_page.dart';
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
      path: AppRoutes.welcomeRoute,
      name: 'welcome',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: AppRoutes.authRoute,
      name: 'auth',
      builder: (context, state) => const AuthPage(),
    ),
    GoRoute(
      path: AppRoutes.onboardingRoute,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutes.layoutRoute,
      name: 'layout',
      builder: (context, state) => const LayoutPage(),
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
    GoRoute(
      path: AppRoutes.personalDetailsRoute,
      name: 'personalDetails',
      builder: (context, state) => const PersonalDetailsPage(),
    ),
    GoRoute(
      path: AppRoutes.scanRemindersRoute,
      name: 'scanReminders',
      builder: (context, state) => const ScanRemindersPage(),
    ),
    // GoRoute(
    //   path: AppRoutes.privacyRoute,
    //   name: 'privacy',
    //   builder: (context, state) => const PrivacyDataPage(),
    // ),
    // GoRoute(
    //   path: AppRoutes.appearanceRoute,
    //   name: 'appearance',
    //   builder: (context, state) => const AppearancePage(),
    // ),
    GoRoute(
      path: AppRoutes.skinTypeRoute,
      name: 'skinType',
      builder: (context, state) => const SkinTypeEditorPage(),
    ),
    GoRoute(
      path: AppRoutes.aiTipsRoute,
      name: 'aiTips',
      builder: (context, state) => const AITipsPage(),
    ),
    GoRoute(
      path: AppRoutes.trendsRoute,
      name: 'trends',
      builder: (context, state) => const TrendsPage(),
    ),
    GoRoute(
      path: AppRoutes.routineRoute,
      name: 'routine',
      builder: (context, state) => const RoutinePage(),
    ),
    GoRoute(
      path: AppRoutes.skinNewsRoute,
      name: 'skinNews',
      builder: (context, state) => const SkinNewsPage(),
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
