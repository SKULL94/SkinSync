import 'package:path/path.dart';
import 'package:skin_sync/model/skin_analysis_history.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('skin_analysis.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE analysis_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imageUrl TEXT NOT NULL,
        results TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertAnalysis(SkinAnalysisHistory history) async {
    final db = await instance.database;
    return await db.insert('analysis_history', history.toMap());
  }

  Future<List<SkinAnalysisHistory>> getAllAnalyses() async {
    final db = await instance.database;
    final maps = await db.query('analysis_history');
    return List.generate(
        maps.length, (i) => SkinAnalysisHistory.fromMap(maps[i]));
  }

  Future<int> deleteAnalysis(int id) async {
    final db = await instance.database;
    return await db.delete(
      'analysis_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllAnalyses() async {
    final db = await instance.database;
    return await db.delete('analysis_history');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
