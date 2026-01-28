import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progress_hub_2/providers/goals_providers.dart';
import '../providers/database_provider.dart';
import '../database/db_constants.dart';

Future<void> showAddEditGoalDialog({
  required BuildContext context,
  required WidgetRef ref,
  int? existingGoalId,
  int? existingSkillId,
}) async {

  final db = ref.read(databaseProvider).value;
  if (db == null) return;

  // Load areas
  final List<Map<String, dynamic>> areas =
  (await db.getAll(SkillAreaTable.table)).cast<Map<String, dynamic>>();

  int? selectedAreaId;
  int? selectedSkillId;

  List<Map<String, dynamic>> skillsInSelectedArea = [];

  if (existingSkillId != null) {
    final List<Map<String, dynamic>> itemRows = (await db.getAll(
      SkillTable.table,
      where: 'id = ?',
      whereArgs: [existingSkillId],
    ))
        .cast<Map<String, dynamic>>();

    if (itemRows.isNotEmpty) {
      final item = itemRows.first;
      selectedSkillId = item['id'] as int;
      selectedAreaId = item['area_id'] as int;

      skillsInSelectedArea = (await db.getAll(
        SkillTable.table,
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
                      SkillTable.table,
                      where: 'area_id = ? AND is_checked = ?',
                      whereArgs: [areaId, 0],
                    ))
                        .cast<Map<String, dynamic>>();

                    setState(() {
                      selectedAreaId = areaId;
                      selectedSkillId = null;
                      skillsInSelectedArea = items;
                    });
                  },
                ),

                const SizedBox(height: 12),

                DropdownButton<int>(
                  isExpanded: true,
                  hint: const Text('Select skill'),
                  value: selectedSkillId,
                  items: skillsInSelectedArea.map((item) {
                    final id = item['id'] as int;
                    final name = (item['name'] ?? '').toString();
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (itemId) {
                    setState(() {
                      selectedSkillId = itemId;
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
                  if (selectedSkillId != null) {
                    final goalsNotifier = ref.read(goalsProvider.notifier);

                    if (existingGoalId == null) {
                      await goalsNotifier.addGoal(selectedSkillId!);
                    } else {
                      await goalsNotifier.updateGoal(existingGoalId, selectedSkillId!);
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
