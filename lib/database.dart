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
      CREATE TABLE skill_area (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
        )
    ''');
    //Table of tennis skills (e.g., athletic position, to bow shoulders)
    await db.execute('''
      CREATE TABLE skill (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      area_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      is_checked INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (area_id) REFERENCES skill_area(id)
          ON DELETE CASCADE
          ON UPDATE CASCADE
      )
    ''');
    //Table of training/game goals (user should selects 1-3 skills)
    await db.execute('''
      CREATE TABLE goal (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      skill_id INTEGER NOT NULL,
      is_checked INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (skill_id) REFERENCES skill(id)
          ON DELETE CASCADE
          ON UPDATE CASCADE 
      )
      ''');
    //Base skill areas
    await db.execute('''
      INSERT INTO skill_area (name)
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
  Future<void> updateGoal(int id, int skillId) async {
    await _db.update(
      'goal',
      {'skill_id': skillId},
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
  Future<List<Map<String, dynamic>>> getCheckedSkillsWithAreaName() async {
    final result = await _db.rawQuery('''
      SELECT
        skill.id AS skill_id,
        skill.name AS skill_name,
        skill.area_id,
        skill_area.name AS area_name,
        skill.is_checked
       FROM skill
       INNER JOIN skill_area
         ON skill.area_id = skill_area.id
       WHERE skill.is_checked = 1  
      ''');

    return result;
  }

  //choosing training/game goals
  Future<List<Map<String, dynamic>>> getGoalsWithAreaSkillName() async {
    final result = await _db.rawQuery('''
    SELECT 
      goal.id,
      skill_area.name AS area_name,
      skill.name AS skill_name,
      goal.skill_id,
      skill.is_checked,
      goal.is_checked
    FROM goal
    INNER JOIN skill
      ON goal.skill_id = skill.id
    INNER JOIN skill_area
      ON skill.area_id = skill_area.id
    WHERE goal.is_checked = 0 AND skill.is_checked = 0
    ''');

    return result;
  }

  Future<List<Map<String, dynamic>>> getMasteredSkills() async {
    final result = await _db.rawQuery('''
    SELECT
      skill.id,
      skill_area.name AS area_name,
      skill.name AS skill_name,
      skill.is_checked
    FROM skill
    INNER JOIN skill_area
      ON skill.area_id = skill_area.id
    WHERE skill.is_checked = 1
    ''');

    return result;
  }
}
