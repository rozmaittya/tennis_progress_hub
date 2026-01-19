import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import '../providers/database_provider.dart';

final progressItemsProvider =
    StateNotifierProvider.family<
      ProgressItemsNotifier,
      List<Map<String, dynamic>>,
      int
    >((ref, areaId) {
      final dbAsync = ref.watch(databaseProvider);
      return dbAsync.maybeWhen(
        data: (db) => ProgressItemsNotifier(db, areaId),
        orElse: () => ProgressItemsNotifier(null, areaId),
      );
    });

class ProgressItemsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final AppDatabase? db;
  final int areaId;

  ProgressItemsNotifier(this.db, this.areaId) : super([]) {
    if (db != null) loadItems();
  }

  Future<void> loadItems() async {
    if (db == null) return;
    final items = await db!.getAll(
      'progress_item',
      where: 'area_id = ? AND is_checked = ?',
      whereArgs: [areaId, 0],
    );
    state = items;
  }

  //Future<void> addItem(int areaId, String name) async {

    Future<void> addItem(String name) async {
    if (db == null) return;
    await db!.insertElement('progress_item', {
      'area_id': areaId,
      'name': name,
      'is_checked': 0,
    });
    await loadItems();
  }

  Future<void> toggleItem(int id, bool isChecked) async {
    if (db == null) return;
    await db!.updateChecked('progress_item', id, isChecked);
    await loadItems();
  }

  Future<void> editItem(int id, String newName) async {
    if (db == null) return;
    await db!.updateName('progress_item', id, newName);
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    if (db == null) return;
    await db!.deleteElement('progress_item', where: 'id = ?', whereArgs: [id]);
  }
}
