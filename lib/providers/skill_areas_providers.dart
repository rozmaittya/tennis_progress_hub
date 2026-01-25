import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import '../providers/database_provider.dart';
import '../database/db_constants.dart';

final areasProvider =
    StateNotifierProvider<AreasNotifier, List<Map<String, dynamic>>>((
      ref,
    ) {
      final dbAsync = ref.watch(databaseProvider);

      return dbAsync.maybeWhen(
        data: (db) => AreasNotifier(db),
        orElse: () => AreasNotifier(null),
      );
    });

class AreasNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final AppDatabase? db;

  AreasNotifier(this.db) : super([]) {
    if (db != null) {
      loadAreas();
    }
  }

  Future<void> loadAreas() async {
    if (db == null) return;

    final areas = await db!.getAll(SkillAreaTable.table);
    state = areas;
  }

  Future<void> addArea(String name) async {
    if (db == null) return;
    await db?.insertElement(SkillAreaTable.table, {SkillAreaTable.name: name});
    await loadAreas();
  }

  Future<void> editArea(int id, String newName) async {
    if (db == null) return;

    await db?.updateName(SkillAreaTable.table, id, newName);
    await loadAreas();
  }

  Future<void> toggleArea(int id, bool isChecked) async {
    if (db == null) return;

    await db?.updateChecked(SkillAreaTable.table, id, isChecked);
    await loadAreas();
  }
}

final areaIdByNameProvider = Provider.family<int?, String>((ref, areaName) {
  final areas = ref.watch(areasProvider);

  for (final a in areas) {
    if (a[SkillAreaTable.name] == areaName) return a[SkillAreaTable.id] as int;
  }
  return null;
});