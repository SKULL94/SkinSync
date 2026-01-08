import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final _connectivityController = StreamController<bool>.broadcast();

  NetworkInfoImpl(this._connectivity) {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final isConnected = results.isNotEmpty &&
            results.first != ConnectivityResult.none;
        _connectivityController.add(isConnected);
      },
    );
  }

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result.isNotEmpty && result.first != ConnectivityResult.none;
  }

  @override
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}
