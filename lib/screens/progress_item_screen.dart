import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/edit_item_dialog.dart';
import '../providers/progress_items_providers.dart';
import '../providers/database_provider.dart';
import '../providers/mastered_screens_providers.dart';
import '../providers/goals_providers.dart';
import '../widgets/tennis_ball_button.dart';
import '../utils/gradient_background.dart';

class ProgressItemScreen extends ConsumerStatefulWidget {
  final int areaId;
  final String areaName;

  const ProgressItemScreen({
    super.key,
    required this.areaId,
    required this.areaName,
  });

  @override
  ConsumerState<ProgressItemScreen> createState() => _ProgressItemScreenState();
}

class _ProgressItemScreenState extends ConsumerState<ProgressItemScreen> {
  Future<void> _toggleItem(int id, bool isChecked) async {
    await ref
        .read(progressItemsProvider(widget.areaId).notifier)
        .toggleItem(id, isChecked);
  }

  Future<void> _editItem(int id, String currentName) async {
    final db = ref.read(databaseProvider).value;
    if (db == null) return;

    await editItemDialog(
      context: context,
      db: db,
      tableName: 'progress_item',
      id: id,
      currentName: currentName,
      onUpdated: () {
        ref.read(progressItemsProvider(widget.areaId).notifier).loadItems();
        ref.invalidate(goalsProvider);
      },
    );
  }

  Future<void> _showAddItemDialog() async {
    String itemName = '';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add new skill'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Input new skill name'),
            onChanged: (value) => itemName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (itemName.trim().isNotEmpty) {
                  Navigator.of(dialogContext).pop(itemName);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name should be not empty')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (result != null) {
      await ref
          .read(progressItemsProvider(widget.areaId).notifier)
          .addItem(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(progressItemsProvider(widget.areaId));

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            widget.areaName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (itemContext, index) {
            final item = items[index];

            return ListTile(
              title: Text(
                (item['name'] ?? '').toString(),
                style: const TextStyle(
                  shadows: [
                    Shadow(
                      offset: Offset(0.5, 0.5),
                      blurRadius: 1.0,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              trailing: Checkbox(
                value: item['is_checked'] == 1,
                onChanged: (bool? value) async {
                  if (value == null) return;

                  if (value == true) {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Mark as learned?'),
                        content: const Text(
                          'Do you really want to mark this skill as fully automated?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: const Text('Yes, mastered'),
                          ),
                        ],
                      ),
                    );

                    if (!mounted || ok != true) return;
                  }

                  await _toggleItem(item['id'] as int, value);
                  ref.invalidate(masteredSkillsProvider);
                },
              ),
              onLongPress: () async {
                final result = await showMenu<String>(
                  context: context,
                  position: const RelativeRect.fromLTRB(200, 200, 50, 50),
                  items: const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                );

                if (!mounted) return;

                if (result == 'edit') {
                  await _editItem(
                    item['id'] as int,
                    (item['name'] ?? '').toString(),
                  );
                  if (!mounted) return;
                } else if (result == 'delete') {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Delete skill?'),
                      content: const Text(
                        'Are you sure you want to delete this skill?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (!mounted) return;

                  if (ok == true) {
                    await ref
                        .read(progressItemsProvider(widget.areaId).notifier)
                        .deleteItem(item['id'] as int);
                    await ref
                        .read(progressItemsProvider(widget.areaId).notifier)
                        .loadItems();
                  }
                }
              },
            );
          },
        ),
        floatingActionButton: TennisBallButton(onPressed: _showAddItemDialog),
      ),
    );
  }
}
