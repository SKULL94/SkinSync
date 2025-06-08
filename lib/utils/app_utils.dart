import 'package:skin_sync/routes/app_routes.dart';
import 'package:skin_sync/utils/app_constants.dart';
import 'package:skin_sync/services/storage.dart';

class AppUtils {
  static String checkUser() {
    return StorageService.instance.fetch(AppConstants.userId) == null
        ? AppRoutes.authRoute
        : AppRoutes.layoutRoute;
  }
}
