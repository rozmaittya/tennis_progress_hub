import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import '../providers/database_provider.dart';
import '../database/db_constants.dart';

final goalsProvider =
StateNotifierProvider<GoalsNotifier, List<Map<String, dynamic>>>(
        (ref) {
  final dbAsync = ref.watch(databaseProvider);

  return dbAsync.maybeWhen(
    data: (db) => GoalsNotifier(db),
    orElse: () => GoalsNotifier(null),
  );
});

class GoalsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final AppDatabase? db;

  GoalsNotifier(this.db) : super([]) {
    if(db != null) {
      loadGoals();
}
}

Future<void> loadGoals() async {
    if(db == null) return;

    final result = await db!.getGoalsWithAreaSkillName();
    state = result;
}

Future<void> addGoal(int skillId) async {
    if(db == null) return;

    await db!.insertElement(GoalTable.table, {GoalTable.skillId: skillId, GoalTable.isChecked: 0});
    await loadGoals();
}

Future<void> updateGoal(int id, int skillId) async {
    if(db == null) return;

    await db!.updateGoal(id, skillId);
}

Future<void> toggleGoal(int id, bool isChecked) async {
    if(db == null) return;

    await db!.updateChecked(GoalTable.table, id, isChecked);
}

Future<void> deleteGoal(int id) async {
    if(db == null) return;

    await db!.deleteElement(GoalTable.table, where: 'id = ?', whereArgs: [id],);
}
}