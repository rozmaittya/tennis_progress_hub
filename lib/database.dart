import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;

  AppDatabase._internal();

  Database? db;

  Database get _db {
    final database = db;
    if (database == null) {
      throw StateError(
        'Database is not initialized. Call initDatabase() first.',
      );
    }
    return database;
  }

  Future<void> initDatabase() async {
    if (db == null) {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'app_database.db');

      db = await openDatabase(
        path,
        version: 3,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: _onCreate,
      );
    }
  }

  //creating database

  //Table of skills areas (e.g., Forehand, Serve)
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE progress_area (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        is_checked INTEGER NOT NULL DEFAULT 0        
        )
    ''');
    //Table of tennis skills (e.g., athletic position, to bow shoulders)
    await db.execute('''
      CREATE TABLE progress_item (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      area_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      is_checked INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (area_id) REFERENCES progress_area(id)
          ON DELETE CASCADE
          ON UPDATE CASCADE
      )
    ''');
    //Table of training/game goals (user should selects 1-3 skills)
    await db.execute('''
      CREATE TABLE goals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      item_id INTEGER NOT NULL,
      is_checked INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (item_id) REFERENCES progress_item(id)
          ON DELETE CASCADE
          ON UPDATE CASCADE 
      )
      ''');
    //Base progress area
    await db.execute('''
      INSERT INTO progress_area (name)
      VALUES ('Forehand'), ('Backhand'), ('Serve'), ('Return'), ('Volley'), ('Overhead'), ('Slice'), ('Drop Shot'), ('Lob'), ('Movement'), ('Tactics'), ('Mindset')
    ''');
  }

  //universal insert function
  Future<void> insertElement(
    String tableName,
    Map<String, dynamic> values,
  ) async {
    await _db.insert(tableName, values);
  }

  //universal select function
  Future<List<Map<String, dynamic>>> getAll(
    String tableName, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return await _db.query(tableName, where: where, whereArgs: whereArgs);
  }

  //universal toggle function
  Future<void> updateChecked(String tableName, int id, bool isChecked) async {
    await _db.update(
      tableName,
      {'is_checked': isChecked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //universal update name function
  Future<void> updateName(String tableName, int id, String newName) async {
    await _db.update(
      tableName,
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //goals table update function
  Future<void> updateGoal(int id, int itemId) async {
    await _db.update(
      'goals',
      {'item_id': itemId},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //universal delete function
  Future<void> deleteElement(
    String tableName, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    await _db.delete(tableName, where: where, whereArgs: whereArgs);
  }

  //close database function
  Future<void> close() async {
    //final db = await database;
    await _db.close();
  }

  //choosing all learned skills function
  Future<List<Map<String, dynamic>>> getCheckedItemsWithAreaName() async {
    final result = await _db.rawQuery('''
      SELECT
        progress_item.id AS item_id,
        progress_item.name AS item_name,
        progress_item.area_id,
        progress_area.name AS area_name,
        progress_item.is_checked
       FROM progress_item
       INNER JOIN progress_area
         ON progress_item.area_id = progress_area.id
       WHERE progress_item.is_checked = 1  
      ''');

    return result;
  }

  //choosing training/game goals
  Future<List<Map<String, dynamic>>> getGoalsWithAreaItemName() async {
    final result = await _db.rawQuery('''
    SELECT 
      goals.id,
      progress_area.name AS area_name,
      progress_item.name AS item_name,
      goals.item_id,
      goals.is_checked
    FROM goals
    INNER JOIN progress_item
      ON goals.item_id = progress_item.id
    INNER JOIN progress_area
      ON progress_item.area_id = progress_area.id
    WHERE goals.is_checked = 0
    ''');

    return result;
  }

  Future<List<Map<String, dynamic>>> getMasteredSkills() async {
    final result = await _db.rawQuery('''
    SELECT
      progress_item.id,
      progress_area.name AS area_name,
      progress_item.name AS item_name,
      progress_item.is_checked
    FROM progress_item
    INNER JOIN progress_area
      ON progress_item.area_id = progress_area.id
    WHERE progress_item.is_checked = 1
    ''');

    return result;
  }
}
