// import 'package:skin_sync/model/routine.dart';
import 'package:skin_sync/routes/app_routes.dart';
import 'package:skin_sync/utils/storage.dart';

class AppUtils {
  static String checkUser() {
    if (StorageService.instance.fetch(userId) == null) {
      return AppRoutes.authRoute;
    } else {
      return AppRoutes.layoutRoute;
    }
  }

  // Storage keys
  static const String userId = "USER_ID";
  static const String userName = "USER_NAME";
}
