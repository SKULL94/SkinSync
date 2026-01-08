import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageService {
  Future<void> save(String key, dynamic value);
  T? fetch<T>(String key);
  Future<void> deleteKey(String key);
  Future<void> clearAll();
}

class StorageServiceImpl implements StorageService {
  final SharedPreferences _preferences;

  StorageServiceImpl(this._preferences);

  @override
  Future<void> save(String key, dynamic value) async {
    if (value is String) {
      await _preferences.setString(key, value);
    } else if (value is int) {
      await _preferences.setInt(key, value);
    } else if (value is double) {
      await _preferences.setDouble(key, value);
    } else if (value is bool) {
      await _preferences.setBool(key, value);
    } else if (value is List<String>) {
      await _preferences.setStringList(key, value);
    }
  }

  @override
  T? fetch<T>(String key) {
    final value = _preferences.get(key);
    if (value is T) {
      return value;
    }
    return null;
  }

  @override
  Future<void> deleteKey(String key) async {
    await _preferences.remove(key);
  }

  @override
  Future<void> clearAll() async {
    await _preferences.clear();
  }
}
