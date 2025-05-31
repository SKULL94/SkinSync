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
      version: 2, // Incremented version for schema update
      onCreate: _createDB,
      onUpgrade: _upgradeDB, // Added for schema migrations
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE analysis_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imageUrl TEXT NOT NULL,
        results TEXT NOT NULL,
        date TEXT NOT NULL,
        user_id TEXT NOT NULL DEFAULT ''  -- Added for Supabase compatibility
      )
    ''');
  }

  // Handle database schema upgrades
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE analysis_history 
        ADD COLUMN user_id TEXT NOT NULL DEFAULT ''
      ''');
    }
  }

  Future<int> insertAnalysis(SkinAnalysisHistory history) async {
    final db = await instance.database;
    return await db.insert('analysis_history', history.toMap());
  }

  Future<List<SkinAnalysisHistory>> getAllAnalyses() async {
    final db = await instance.database;
    final maps = await db.query('analysis_history');
    return maps.map((map) => SkinAnalysisHistory.fromMap(map)).toList();
  }

  // Get analyses for specific user
  Future<List<SkinAnalysisHistory>> getUserAnalyses(String userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'analysis_history',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => SkinAnalysisHistory.fromMap(map)).toList();
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

  // Delete all analyses for a specific user
  Future<int> deleteUserAnalyses(String userId) async {
    final db = await instance.database;
    return await db.delete(
      'analysis_history',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
