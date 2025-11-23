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
        version: 2, // Erhöhe die Version bei Datenbankänderungen
        onCreate: _onCreate,
        //onUpgrade: _onUpgrade,
      );
    }

  }

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

//ДОДАТИ ЦІ ТРИ УНІВЕРСАЛЬНИХ МЕТОДА
  Future<void> insert(String tableName, Map<String, dynamic> values) async {
    await db!.insert(tableName, values);
  }

  Future<List<Map<String, dynamic>>> getAll(String tableName,
      {String? where, List<Object?>? whereArgs}) async {
    return await db!.query(tableName, where: where, whereArgs: whereArgs);
  }

  Future<void> updateChecked(String tableName, int id, bool isChecked) async {
    await db!.update(
      tableName,
      {'is_checked': isChecked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateName(String tableName, int id, String newName) async {
    await db!.update(
        tableName,
        {'name': newName},
      where: 'id = ?',
        whereArgs: [id],
    );
  }


  Future<void> updateStatus(String tableName,int id, bool isChecked) async {
    //final db = await database;
    await db!.update(
      tableName,
      {'is_checked': isChecked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAreas() async {
    //final db = await database;
    final result =  await db!.query('progress_area');
    return result;
  }
  Future<List<Map<String, dynamic>>> getItems() async {
    //final db = await database;
    final result =  await db!.query('progress_item');
    return result;
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


}
