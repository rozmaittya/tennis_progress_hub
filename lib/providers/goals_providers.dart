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

    final result = await db!.getCheckedItemsWithAreaName();
    state = result;
}
}