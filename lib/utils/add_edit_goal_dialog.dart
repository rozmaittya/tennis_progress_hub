import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progress_hub_2/providers/goals_providers.dart';
import '../providers/database_provider.dart';

Future<void> showAddEditGoalDialog({
  required BuildContext context,
  required WidgetRef ref,
  int? existingGoalId,
  int? existingItemId,
}) async {

  final db = ref.read(databaseProvider).value;
  if (db == null) return;

  // Load areas
  final List<Map<String, dynamic>> areas =
  (await db.getAll('progress_area')).cast<Map<String, dynamic>>();

  int? selectedAreaId;
  int? selectedItemId;

  List<Map<String, dynamic>> itemsInSelectedArea = [];

  if (existingItemId != null) {
    final List<Map<String, dynamic>> itemRows = (await db.getAll(
      'progress_item',
      where: 'id = ?',
      whereArgs: [existingItemId],
    ))
        .cast<Map<String, dynamic>>();

    if (itemRows.isNotEmpty) {
      final item = itemRows.first;
      selectedItemId = item['id'] as int;
      selectedAreaId = item['area_id'] as int;

      itemsInSelectedArea = (await db.getAll(
        'progress_item',
        where: 'area_id = ?',
        whereArgs: [selectedAreaId],
      ))
          .cast<Map<String, dynamic>>();
    }
  }

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existingGoalId == null ? 'Add goal' : 'Edit goal'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<int>(
                  isExpanded: true,
                  hint: const Text('Select area'),
                  value: selectedAreaId,
                  items: areas.map((area) {
                    final id = area['id'] as int;
                    final name = (area['name'] ?? '').toString();
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (areaId) async {
                    if (areaId == null) return;

                    final items = (await db.getAll(
                      'progress_item',
                      where: 'area_id = ? AND is_checked = ?',
                      whereArgs: [areaId, 0],
                    ))
                        .cast<Map<String, dynamic>>();

                    setState(() {
                      selectedAreaId = areaId;
                      selectedItemId = null;
                      itemsInSelectedArea = items;
                    });
                  },
                ),

                const SizedBox(height: 12),

                DropdownButton<int>(
                  isExpanded: true,
                  hint: const Text('Select skill'),
                  value: selectedItemId,
                  items: itemsInSelectedArea.map((item) {
                    final id = item['id'] as int;
                    final name = (item['name'] ?? '').toString();
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (itemId) {
                    setState(() {
                      selectedItemId = itemId;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (selectedItemId != null) {
                    final goalsNotifier = ref.read(goalsProvider.notifier);

                    if (existingGoalId == null) {
                      await goalsNotifier.addGoal(selectedItemId!);
                    } else {
                      await goalsNotifier.updateGoal(existingGoalId, selectedItemId!);
                    }

                    await goalsNotifier.loadGoals();

                    if (!dialogContext.mounted) return;
                    Navigator.of(dialogContext).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select skill')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}
