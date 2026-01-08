import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skin_sync/core/constants/app_constants.dart';
import 'package:skin_sync/core/services/storage_service.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final StorageService storageService;

  ThemeBloc({required this.storageService}) : super(const ThemeState()) {
    on<ThemeLoadRequested>(_onLoadRequested);
    on<ThemeChanged>(_onThemeChanged);
  }

  void _onLoadRequested(
    ThemeLoadRequested event,
    Emitter<ThemeState> emit,
  ) {
    final themeString = storageService.fetch<String>(AppConstants.theme) ??
        AppConstants.systemTheme;
    final themeMode = _stringToThemeMode(themeString);
    emit(state.copyWith(themeMode: themeMode));
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    final themeString = _themeModeToString(event.themeMode);
    await storageService.save(AppConstants.theme, themeString);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  ThemeMode _stringToThemeMode(String themeString) {
    return switch (themeString) {
      AppConstants.darkTheme => ThemeMode.dark,
      AppConstants.lightTheme => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  String _themeModeToString(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.dark => AppConstants.darkTheme,
      ThemeMode.light => AppConstants.lightTheme,
      ThemeMode.system => AppConstants.systemTheme,
    };
  }
}
