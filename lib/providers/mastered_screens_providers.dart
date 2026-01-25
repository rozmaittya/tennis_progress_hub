import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import '../providers/database_provider.dart';
import '../database/db_constants.dart';

final masteredSkillsProvider =
StateNotifierProvider<MasteredSkillsNotifier, List<Map<String, dynamic>>>(
    (ref) {
      final dbAsync = ref.watch(databaseProvider);

      return dbAsync.maybeWhen(
          data: (db) => MasteredSkillsNotifier(db),
          orElse: () => MasteredSkillsNotifier(null),
      );
    }
);

class MasteredSkillsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final AppDatabase? db;

  MasteredSkillsNotifier(this.db) : super([]) {
    if (db != null) {
      loadMasteredSkills();
    }
  }

  Future<void> loadMasteredSkills() async {
    if (db == null) return;

    final masteredSkills = await db!.getMasteredSkills();
    state = masteredSkills;
  }

  Future<void> toggleMasteredSkill(int id, bool isChecked) async {
    if (db == null) return;

    await db!.updateChecked(SkillTable.table, id, isChecked);
    await loadMasteredSkills();
  }
}