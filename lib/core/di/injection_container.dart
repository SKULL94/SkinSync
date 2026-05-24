import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:skin_sync/core/repositories/user_repository.dart';
import 'package:skin_sync/core/services/network_info.dart';
import 'package:skin_sync/core/services/storage_service.dart';
import 'package:skin_sync/core/services/notification_service.dart';
import 'package:skin_sync/core/services/sqflite_database.dart';
import 'package:skin_sync/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:skin_sync/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:skin_sync/features/auth/domain/repositories/auth_repository.dart';
import 'package:skin_sync/features/auth/domain/usecases/send_otp.dart';
import 'package:skin_sync/features/auth/domain/usecases/verify_otp.dart';
import 'package:skin_sync/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:skin_sync/features/history/data/datasources/history_local_data_source.dart';
import 'package:skin_sync/features/history/data/datasources/history_remote_data_source.dart';
import 'package:skin_sync/features/history/data/repositories/history_repository_impl.dart';
import 'package:skin_sync/features/history/domain/repositories/history_repository.dart';
import 'package:skin_sync/features/history/domain/usecases/delete_all_histories.dart';
import 'package:skin_sync/features/history/domain/usecases/delete_history.dart';
import 'package:skin_sync/features/history/domain/usecases/get_histories.dart';
import 'package:skin_sync/features/history/domain/usecases/sync_histories.dart';
import 'package:skin_sync/features/history/presentation/bloc/history_bloc.dart';
import 'package:skin_sync/features/layout/presentation/bloc/layout_bloc.dart';
import 'package:skin_sync/features/skin_analysis/data/datasources/skin_analysis_local_data_source.dart';
import 'package:skin_sync/features/skin_analysis/data/datasources/skin_analysis_remote_data_source.dart';
import 'package:skin_sync/features/skin_analysis/data/repositories/skin_analysis_repository_impl.dart';
import 'package:skin_sync/features/skin_analysis/domain/repositories/skin_analysis_repository.dart';
import 'package:skin_sync/features/skin_analysis/domain/usecases/analyze_image.dart';
import 'package:skin_sync/features/skin_analysis/domain/usecases/save_analysis.dart';
import 'package:skin_sync/features/skin_analysis/presentation/bloc/skin_analysis_bloc.dart';
import 'package:skin_sync/features/settings/presentation/bloc/theme_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => Supabase.instance.client);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => DatabaseHelper.instance);

  // Core
  sl.registerLazySingleton<StorageService>(
    () => StorageServiceImpl(sl()),
  );
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  // Services
  sl.registerLazySingleton(() => NotificationService());

  // Repositories
  sl.registerLazySingleton(() => UserRepository(supabaseClient: sl()));

  // Features - Auth
  _initAuth();

  // Features - Skin Analysis
  _initSkinAnalysis();

  // Features - History
  _initHistory();

  // Features - Layout
  _initLayout();

  // Features - Settings
  _initSettings();
}

void _initAuth() {
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      sendOtp: sl(),
      verifyOtp: sl(),
      storageService: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SendOtp(sl()));
  sl.registerLazySingleton(() => VerifyOtp(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );
}

void _initSkinAnalysis() {
  // Bloc
  sl.registerFactory(
    () => SkinAnalysisBloc(
      analyzeImage: sl(),
      saveAnalysis: sl(),
      storageService: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => AnalyzeImage(sl()));
  sl.registerLazySingleton(() => SaveAnalysis(sl()));

  // Repository
  sl.registerLazySingleton<SkinAnalysisRepository>(
    () => SkinAnalysisRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<SkinAnalysisLocalDataSource>(
    () => SkinAnalysisLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<SkinAnalysisRemoteDataSource>(
    () => SkinAnalysisRemoteDataSourceImpl(),
  );
}

void _initHistory() {
  // Bloc
  sl.registerFactory(
    () => HistoryBloc(
      getHistories: sl(),
      deleteHistory: sl(),
      deleteAllHistories: sl(),
      syncHistories: sl(),
      storageService: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetHistories(sl()));
  sl.registerLazySingleton(() => DeleteHistory(sl()));
  sl.registerLazySingleton(() => DeleteAllHistories(sl()));
  sl.registerLazySingleton(() => SyncHistories(sl()));

  // Repository
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<HistoryLocalDataSource>(
    () => HistoryLocalDataSourceImpl(databaseHelper: sl()),
  );
  sl.registerLazySingleton<HistoryRemoteDataSource>(
    () => HistoryRemoteDataSourceImpl(),
  );
}

void _initLayout() {
  // Bloc
  sl.registerFactory(() => LayoutBloc());
}

void _initSettings() {
  // Bloc
  sl.registerFactory(
    () => ThemeBloc(storageService: sl()),
  );
}
