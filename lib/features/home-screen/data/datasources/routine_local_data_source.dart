import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:skin_sync/core/error/exceptions.dart';

abstract class RoutineLocalDataSource {
  Future<String> saveIcon(String routineId, File iconFile);
  Future<void> deleteIcon(String routineId);
}

class RoutineLocalDataSourceImpl implements RoutineLocalDataSource {
  @override
  Future<String> saveIcon(String routineId, File iconFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final iconDir = Directory('${directory.path}/routine_icons');
      if (!await iconDir.exists()) {
        await iconDir.create(recursive: true);
      }

      final path = '${iconDir.path}/$routineId.png';
      await iconFile.copy(path);
      return path;
    } catch (e) {
      throw CacheException(message: 'Failed to save icon: $e');
    }
  }

  @override
  Future<void> deleteIcon(String routineId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final iconFile = File('${directory.path}/routine_icons/$routineId.png');
      if (await iconFile.exists()) {
        await iconFile.delete();
      }
    } catch (e) {
      throw CacheException(message: 'Failed to delete icon: $e');
    }
  }
}
