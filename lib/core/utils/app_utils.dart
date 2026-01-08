import 'package:skin_sync/core/constants/app_constants.dart';
import 'package:skin_sync/core/services/storage_service.dart';
import 'package:skin_sync/core/di/injection_container.dart';
import 'package:skin_sync/core/routes/app_routes.dart';

class AppUtils {
  static String checkUser() {
    final storageService = sl<StorageService>();
    final userId = storageService.fetch<String>(AppConstants.userId);
    return userId == null || userId.isEmpty
        ? AppRoutes.authRoute
        : AppRoutes.layoutRoute;
  }
}
