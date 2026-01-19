import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import '../providers/database_provider.dart';

final progressAreasProvider =
    StateNotifierProvider<ProgressAreasNotifier, List<Map<String, dynamic>>>((
      ref,
    ) {
      final dbAsync = ref.watch(databaseProvider);

      return dbAsync.maybeWhen(
        data: (db) => ProgressAreasNotifier(db),
        orElse: () => ProgressAreasNotifier(null),
      );
    });

class ProgressAreasNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final AppDatabase? db;

  ProgressAreasNotifier(this.db) : super([]) {
    if (db != null) {
      loadAreas();
    }
  }

  Future<void> loadAreas() async {
    if (db == null) return;

    final areas = await db!.getAll('progress_area');
    state = areas;
  }

  Future<void> addArea(String name) async {
    if (db == null) return;
    await db?.insertElement('progress_area', {'name': name, 'is_checked': 0});
    await loadAreas();
  }

  Future<void> editArea(int id, String newName) async {
    if (db == null) return;

    await db?.updateName('progress_area', id, newName);
    await loadAreas();
  }

  Future<void> toggleArea(int id, bool isChecked) async {
    if (db == null) return;

    await db?.updateChecked('progress_area', id, isChecked);
    await loadAreas();
  }
}

final areaIdByNameProvider = Provider.family<int?, String>((ref, areaName) {
  final areas = ref.watch(progressAreasProvider);

  for (final a in areas) {
    if (a['name'] == areaName) return a['id'] as int;
  }
  return null;
});