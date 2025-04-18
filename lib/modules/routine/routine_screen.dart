import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/model/routine.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/utils/app_utils.dart';
import 'package:skin_sync/utils/storage.dart';

class RoutineScreen extends StatelessWidget {
  const RoutineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RoutineController controller = Get.put(RoutineController());
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xffFCF7FA),
      appBar: AppBar(
        title: const Text('Daily Skincare'),
        centerTitle: true,
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: SingleChildScrollView(
          child: Obx(
            () => controller.isLoading || controller.isFetchingImage
                ? SizedBox(
                    height: size.height,
                    width: size.width,
                    child: const Center(child: CircularProgressIndicator()))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.routineData.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data = controller.routineData[index];
                      RoutineStaticData staticData =
                          AppUtils.staticRoutineData[index];
                      return ListTile(
                        leading: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xffF2E8EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                              child: data["isRoutineDone"]
                                  ? const Icon(
                                      Icons.done,
                                      color: Colors.green,
                                    )
                                  : const Icon(
                                      Icons.dangerous_rounded,
                                      color: Colors.amber,
                                    )),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              staticData.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              data["completedDate"] == ""
                                  ? ""
                                  : controller
                                      .convertTime(data["completedDate"] ?? ""),
                              style: const TextStyle(
                                  color: Color(0xff964F66), fontSize: 14),
                            )
                          ],
                        ),
                        subtitle: Text(
                          staticData.desc,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Color(0xff964F66),
                          ),
                        ),
                        trailing: data["imagePath"] == ""
                            ? IconButton(
                                icon: const Icon(Icons.camera_enhance_outlined),
                                onPressed: () =>
                                    controller.uploadImageAndSaveRoutine(
                                        StorageService.instance
                                            .fetch(AppUtils.userId),
                                        data["routineId"]),
                              )
                            : Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xffF2E8EB),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                      imageUrl: data["imagePath"],
                                      fit: BoxFit.fill,
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error)),
                                ),
                              ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
