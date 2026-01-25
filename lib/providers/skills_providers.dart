import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import '../providers/database_provider.dart';
import '../database/db_constants.dart';

final skillsProvider =
    StateNotifierProvider.family<
      SkillsNotifier,
      List<Map<String, dynamic>>,
      int
    >((ref, areaId) {
      final dbAsync = ref.watch(databaseProvider);
      return dbAsync.maybeWhen(
        data: (db) => SkillsNotifier(db, areaId),
        orElse: () => SkillsNotifier(null, areaId),
      );
    });

class SkillsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final AppDatabase? db;
  final int areaId;

  SkillsNotifier(this.db, this.areaId) : super([]) {
    if (db != null) loadSkills();
  }

  Future<void> loadSkills() async {
    if (db == null) return;
    final items = await db!.getAll(
      SkillTable.table,
      where: 'area_id = ? AND is_checked = ?',
      whereArgs: [areaId, 0],
    );
    state = items;
  }

  Future<void> addSkill(String name) async {
    if (db == null) return;
    await db!.insertElement(SkillTable.table, {
      SkillTable.areaId: areaId,
      SkillTable.name: name,
      SkillTable.isChecked: 0,
    });
    await loadSkills();
  }

  Future<void> toggleSkill(int id, bool isChecked) async {
    if (db == null) return;
    await db!.updateChecked(SkillTable.table, id, isChecked);
    await loadSkills();
  }

  Future<void> editSkill(int id, String newName) async {
    if (db == null) return;
    await db!.updateName(SkillTable.table, id, newName);
    await loadSkills();
  }

  Future<void> deleteSkill(int id) async {
    if (db == null) return;
    await db!.deleteElement(SkillTable.table, where: 'id = ?', whereArgs: [id]);
  }
}
