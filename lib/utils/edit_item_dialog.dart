import 'package:flutter/material.dart';
import '../database.dart';

Future<void> editItemDialog({
  required BuildContext context,
  required AppDatabase db,
  required String tableName,
  required int id,
  required String currentName,
  required VoidCallback onUpdated,
}) async {
  String updatedName = currentName;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(tableName == 'progress_item' ? 'Edit skill' :'Edit name'),
        content: TextField(
          autofocus: true,
          controller: TextEditingController(text: currentName),
          decoration: const InputDecoration(hintText: 'Input new name'),
          onChanged: (value) => updatedName = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (updatedName.trim().isNotEmpty) {
                Navigator.of(context).pop(updatedName);
              }
            },
            child: const Text('Renew'),
          ),
        ],
      );
    },
  ).then((result) async {
    if (result != null && result is String) {
      await db.updateName(tableName, id, result);
      onUpdated();
    }
  });
}