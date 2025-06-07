import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/utils/custom_snackbar.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  final Rx<ConnectivityResult> connectionStatus = ConnectivityResult.none.obs;
  SnackbarController? _snackbarController;
  bool _wasOffline = false;

  @override
  void onInit() {
    super.onInit();
    initConnectivity();

    ever(connectionStatus, (ConnectivityResult status) {
      if (status == ConnectivityResult.none) {
        if (_snackbarController == null) {
          _wasOffline = true;
          _snackbarController = showCustomSnackbar(
            'Error',
            '⚠️ No Internet: Please check your network settings.',
            duration: const Duration(days: 1),
          );
        }
      } else {
        if (_snackbarController != null) {
          _snackbarController!.close();
          _snackbarController = null;
        }
        if (_wasOffline) {
          showCustomSnackbar(
            'Back Online',
            '✅ Internet connection is restored.',
            duration: const Duration(seconds: 3),
          );
          _wasOffline = false;
        }
      }
    });

    _subscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      connectionStatus.value =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
    });
  }

  Future<void> initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      connectionStatus.value =
          result.isNotEmpty ? result.first : ConnectivityResult.none;
    } catch (e) {
      debugPrint("Error checking connectivity: $e");
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
