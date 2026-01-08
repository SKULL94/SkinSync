import 'package:go_router/go_router.dart';
import 'package:skin_sync/features/auth/presentation/pages/auth_page.dart';
import 'package:skin_sync/features/history/presentation/pages/history_page.dart';
import 'package:skin_sync/features/layout/presentation/pages/layout_page.dart';
import 'package:skin_sync/features/routine/presentation/pages/create_routine_page.dart';
import 'package:skin_sync/features/routine/presentation/pages/routine_page.dart';
import 'package:skin_sync/features/skin_analysis/presentation/pages/skin_analysis_page.dart';
import 'package:skin_sync/features/splash/presentation/pages/splash_page.dart';
import 'package:skin_sync/features/streaks/presentation/pages/streaks_page.dart';
import 'package:skin_sync/core/routes/app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splashScreen,
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
      path: AppRoutes.createRoutineRoute,
      name: 'createRoutine',
      builder: (context, state) => const CreateRoutinePage(),
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
