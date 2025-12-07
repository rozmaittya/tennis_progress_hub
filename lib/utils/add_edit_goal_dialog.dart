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

  List<Map<String, dynamic>> itemsInSelectedArea = [];

  if (db == null) return;

  //select all areas
  final areas = await db.getAll('progress_area');
  Map<String, dynamic>? selectedArea;
  Map<String, dynamic>? selectedItem;

  if (existingItemId != null) {
    final items = await db.getAll(
      'progress_item',
      where: 'id = ?',
      whereArgs: [existingItemId],
    );
    if (items.isNotEmpty) {
      selectedItem = items.first;
      final area = await db.getAll(
        'progress_area',
        where: 'area_id = ?',
        whereArgs: [selectedItem['area_id']],
      );
      if (area.isNotEmpty) {
        selectedArea = area.first;
          itemsInSelectedArea = await db.getAll(
            'progress_item',
            where: 'area_id = ?',
            whereArgs: [selectedArea['id']],
          );
      }
    }
  }
  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existingGoalId == null ? 'Add goal' : 'Edit goal'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //Dropdown areas
                DropdownButton<Map<String, dynamic>>(
                  isExpanded: true,
                  hint: const Text('select Area'),
                  value: selectedArea,
                  items: areas.map((area) {
                    return DropdownMenuItem(
                      value: area,
                      child: Text(area['name']),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    final items = await db.getAll(
                      'progress_item',
                      where: 'area_id = ?',
                      whereArgs: [value!['id']],
                    );

                    setState(() {
                      selectedArea = value;
                      selectedItem = null;
                      itemsInSelectedArea = items;
                    });
                  },
                ),

                const SizedBox(height: 12),

                DropdownButton<Map<String, dynamic>>(
                  isExpanded: true,
                  hint: Text('Select skill'),
                  value: selectedItem,
                  items: itemsInSelectedArea.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedItem = value;
                    });
                  },
                ),
              ],
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (selectedItem != null) {
                    final goalsNotifier = ref.read(goalsProvider.notifier);

                    if (existingGoalId == null) {
                      await goalsNotifier.addGoal(selectedItem!['id']);
                    } else {
                      await goalsNotifier.updateGoal(
                        existingGoalId,
                        selectedItem!['id'],
                      );
                    }

                    await goalsNotifier.loadGoals();
                    Navigator.of(context).pop();
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
