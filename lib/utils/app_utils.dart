import 'package:skin_sync/model/routine.dart';
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

  static List staticRoutineData = [
    RoutineStaticData(name: "Cleanser", desc: "Cetaphil Gentle Skin Cleanser"),
    RoutineStaticData(name: "Toner", desc: "Thayers Witch Hazel Toner"),
    RoutineStaticData(name: "Moisturizer", desc: "Kiehl's Ultra Facial Cream"),
    RoutineStaticData(
        name: "Sunscreen",
        desc: "Supergoop Unseen Sunscreen SPF 40 & 24 hour protection."),
    RoutineStaticData(name: "Lip Balm", desc: "Glossier Birthday Balm Dotcom"),
  ];
}
