import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

class StorageService {
  StorageService._();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static final instance = StorageService._();

  final blackBox = GetStorage();

  save(String key, dynamic value) {
    blackBox.write(key, value);
  }

  fetch(String key) {
    return blackBox.read(key);
  }

  deleteKey(String key) {
    blackBox.remove(key);
  }

  clearAll() {
    blackBox.erase();
  }

  Future<void> secureSave(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> secureFetch(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> secureDelete(String key) async {
    await _secureStorage.delete(key: key);
  }
}
