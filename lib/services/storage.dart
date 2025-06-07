import 'package:get_storage/get_storage.dart';

class StorageService {
  StorageService._();

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
}
