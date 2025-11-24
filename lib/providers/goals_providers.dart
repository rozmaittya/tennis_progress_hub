import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import '../providers/database_provider.dart';

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

    final result = await db!.getGoalsWithAreaItemName();
    state = result;
}

Future<void> addGoal(int item_id) async {
    if(db == null) return;

    await db!.insertElement('goals', {'item_id': item_id, 'is_checked': 0});
    await loadGoals();
}

Future<void> updateGoal(int id, int item_id) async {
    if(db == null) return;

    await db!.updateGoal(id, item_id);
}

Future<void> toggleGoal(int id, bool isChecked) async {
    if(db == null) return;

    await db!.updateChecked('goals', id, isChecked);
}

Future<void> deleteGoal(int id) async {
    if(db == null) return;

    await db!.deleteElement('goals', where: 'id = ?', whereArgs: [id],);
}
}