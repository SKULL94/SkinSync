import 'package:get/get.dart';
import 'package:skin_sync/modules/auth/auth_binding.dart';
import 'package:skin_sync/modules/auth/auth_screen.dart';
import 'package:skin_sync/modules/history/skin_analysis_binding.dart';
import 'package:skin_sync/modules/history/skin_analysis_history_screen.dart';
import 'package:skin_sync/modules/layout/layout_binding.dart';
import 'package:skin_sync/modules/layout/layout_screen.dart';
import 'package:skin_sync/modules/routine/custom_routine_screen.dart';
import 'package:skin_sync/modules/routine/routine_binding.dart';
import 'package:skin_sync/modules/routine/routine_screen.dart';
import 'package:skin_sync/modules/skinanalysis/skincare_analysis_binding.dart';
import 'package:skin_sync/modules/skinanalysis/skincare_analysis_screen.dart';
import 'package:skin_sync/modules/streaks/streaks_binding.dart';
import 'package:skin_sync/modules/streaks/streaks_screen.dart';
import 'package:skin_sync/routes/app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
        name: AppRoutes.authRoute,
        page: () => const AuthScreen(),
        binding: AuthBinding()),
    GetPage(
        name: AppRoutes.streaksRoute,
        page: () => StreaksScreen(),
        binding: StreaksBinding()),
    GetPage(
        name: AppRoutes.routineRoute,
        page: () => RoutineScreen(),
        binding: RoutineBinding()),
    GetPage(
        name: AppRoutes.layoutRoute,
        page: () => const LayoutScreen(),
        bindings: [
          SkincareAnalysisBinding(),
          LayoutBinding(),
          RoutineBinding(),
          StreaksBinding(),
        ]),
    GetPage(
      name: AppRoutes.createRoutineRoute,
      page: () => CreateRoutineScreen(),
      binding: RoutineBinding(),
    ),
    GetPage(
      name: AppRoutes.skinAnalysisRoute,
      page: () => SkincareAnalysisScreen(),
      binding: SkincareAnalysisBinding(),
    ),
    GetPage(
      name: AppRoutes.historyRoute,
      page: () => HistoryScreen(),
      binding: SkinAnalysisBinding(),
    ),
  ];
}
