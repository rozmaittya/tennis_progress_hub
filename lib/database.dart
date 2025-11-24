import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;

  AppDatabase._internal();

  Database? db;

  Future<void> initDatabase() async {
    if(db == null ){
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'app_database.db');

      db = await openDatabase(
        path,
        version: 3, // Erhöhe die Version bei Datenbankänderungen
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }

  }

  //creating database
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE progress_area (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
      is_checked INTEGER NOT NULL DEFAULT 0        
        )
    ''');
    await db.execute('''
      CREATE TABLE progress_item (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      area_id INT NOT NULL,
      name TEXT NOT NULL,
      is_checked INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (area_id) REFERENCES progress_area(id)
          ON DELETE CASCADE
          ON UPDATE CASCADE
      )
    ''');
  }

  //upgrade database adding table "goals"
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if(oldVersion<3) {
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
    }
  }

  //universal insert function
  Future<void> insertElement(String tableName, Map<String, dynamic> values) async {
    await db!.insert(tableName, values);
  }

  //universal select function
  Future<List<Map<String, dynamic>>> getAll(String tableName,
      {String? where, List<Object?>? whereArgs}) async {
    return await db!.query(tableName, where: where, whereArgs: whereArgs);
  }

  //universal toggle function
  Future<void> updateChecked(String tableName, int id, bool isChecked) async {
    await db!.update(
      tableName,
      {'is_checked': isChecked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
 //universal update name function
  Future<void> updateName(String tableName, int id, String newName) async {
    await db!.update(
        tableName,
        {'name': newName},
      where: 'id = ?',
        whereArgs: [id],
    );
  }

  Future<void> updateGoal(int id, int item_id) async {
    await db!.update(
    'goals',
    {'item_id': item_id},
        where: 'id = ?',
        whereArgs: [id],
    );
  }
  //universal delete function
  Future<void> deleteElement(String tableName, {String? where, List<Object?>? whereArgs}) async {
    await db!.delete(tableName, where: where, whereArgs: whereArgs);
  }

  Future<void> close() async {
    //final db = await database;
    await db!.close();
  }

    Future<List<Map<String, dynamic>>> getCheckedItemsWithAreaName() async {
      final result = await db!.rawQuery('''
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

    Future<List<Map<String, dynamic>>> getGoalsWithAreaItemName() async {
    final result = await db!.rawQuery('''
    SELECT 
      goals.id,
      progress_area.name AS area_name,
      progress_item.name AS item_name,
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
}
