import 'package:flutter/material.dart';
import '../utils/edit_item_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/progress_items_providers.dart';
import '../providers/database_provider.dart';
import '../widgets/tennis_ball_button.dart';
import '../utils/gradient_background.dart';

class ProgressItemScreen extends ConsumerStatefulWidget {
  final int areaId;
  final String areaName;

  const ProgressItemScreen({
    required this.areaId,
    required this.areaName,
    Key? key,
  }) : super(key: key);

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
      onUpdated: () =>
          ref.read(progressItemsProvider(widget.areaId).notifier).loadItems(),
    );
  }

  Future<void> _showAddItemDialog() async {
    String itemName = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add new element'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Input new element'),
            onChanged: (value) => itemName = value,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (itemName.trim().isNotEmpty) {
                  Navigator.of(context).pop(itemName);
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
    ).then((result) async {
      if (result != null && result is String) {
        await ref
            .read(progressItemsProvider(widget.areaId).notifier)
            .addItem(widget.areaId, result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(progressItemsProvider(widget.areaId));
    return GradientBackground(
      colors: [Colors.greenAccent, Colors.orange],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            title: Text(widget.areaName),
            backgroundColor: Colors.transparent,
        ),
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              title: Text(item['name']),
              trailing: Checkbox(
                value: item['is_checked'] == 1,
                onChanged: (bool? value) {
                  if (value != null) {
                    _toggleItem(item['id'], value);
                  }
                },
              ),
              onLongPress: () => _editItem(item['id'], item['name']),
            );
          },
        ),

        floatingActionButton: TennisBallButton(onPressed: _showAddItemDialog),
      ),
    );
  }
}
