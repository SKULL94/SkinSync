import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skin_sync/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:skin_sync/features/history/presentation/bloc/history_bloc.dart';
import 'package:skin_sync/features/layout/presentation/bloc/layout_bloc.dart';
import 'package:skin_sync/features/routine/presentation/bloc/routine_bloc.dart';
import 'package:skin_sync/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:skin_sync/features/skin_analysis/presentation/bloc/skin_analysis_bloc.dart';
import 'package:skin_sync/features/streaks/presentation/bloc/streaks_bloc.dart';
import 'package:skin_sync/core/di/injection_container.dart';
import 'package:skin_sync/core/routes/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
        ),
        BlocProvider<RoutineBloc>(
          create: (_) => sl<RoutineBloc>(),
        ),
        BlocProvider<SkinAnalysisBloc>(
          create: (_) => sl<SkinAnalysisBloc>(),
        ),
        BlocProvider<StreaksBloc>(
          create: (_) => sl<StreaksBloc>(),
        ),
        BlocProvider<HistoryBloc>(
          create: (_) => sl<HistoryBloc>(),
        ),
        BlocProvider<LayoutBloc>(
          create: (_) => sl<LayoutBloc>(),
        ),
        BlocProvider<ThemeBloc>(
          create: (_) => sl<ThemeBloc>()..add(const ThemeLoadRequested()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            theme: FlexThemeData.light(
              scheme: FlexScheme.bahamaBlue,
              useMaterial3: true,
            ),
            darkTheme: FlexThemeData.dark(
              scheme: FlexScheme.damask,
              useMaterial3: true,
            ),
            themeMode: themeState.themeMode,
            debugShowCheckedModeBanner: false,
            title: 'Daily Skin Care Routine App',
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
