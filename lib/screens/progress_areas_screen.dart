// Додаток для вдосконалення гри у теніс для Flutter
import 'package:flutter/material.dart';
import 'package:progress_hub_2/providers/goals_providers.dart';
import '../providers/progress_areas_providers.dart';
import '../screens/progress_item_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/tennis_ball_button.dart';
import '../utils/gradient_background.dart';
import '../providers/mastered_screens_providers.dart';

class ProgressAreasScreen extends ConsumerStatefulWidget {
  const ProgressAreasScreen({super.key});

  @override
  ConsumerState<ProgressAreasScreen> createState() =>
      _ProgressAreasScreenState();
}

class _ProgressAreasScreenState extends ConsumerState<ProgressAreasScreen> {

  //editing progress area name
  Future<void> _editItem(int id, String currentName) async {
    String updatedName = currentName;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit name'),
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
                if (updatedName
                    .trim()
                    .isNotEmpty) {
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
        await ref.read(progressAreasProvider.notifier).editArea(id, result);
        ref.invalidate(masteredSkillsProvider);
        ref.invalidate(goalsProvider);

      }
    });
  }

// we don't need this option for progress area now
//   Future<void> _toggleItem(int id, bool isChecked) async {
//     await ref.read(progressAreasProvider.notifier).toggleArea(id, isChecked);
//   }

//adding new progress area
  Future<void> _showAddItemDialog() async {
    String itemName = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        // ignore: prefer_const_constructors
        return AlertDialog(
          title: const Text('Add new progress area'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Input progress area name',
            ),
            onChanged: (value) {
              itemName = value;
            },
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
                if (itemName
                    .trim()
                    .isNotEmpty) {
                  Navigator.of(context).pop(itemName);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name can\'t be empty')),
                  );

                }
              },
              child: const Text('Додати'),
            ),
          ],
        );
      },
    ).then((result) async {
      if (result != null && result is String) {
        await ref.read(progressAreasProvider.notifier).addArea(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(progressAreasProvider);

     return  Scaffold(
       backgroundColor: Colors.transparent,
       body:
       ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: Icon(Icons.sports_tennis),
            title: Text(item['name'], style:
              TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProgressItemScreen(
                        areaId: item['id'],
                        areaName: item['name'],
                      ),
                ),
              );
            },
            onLongPress: () =>
                _editItem(item['id'], item['name']),
          );
        },
      ),

       floatingActionButton: TennisBallButton(
        onPressed: _showAddItemDialog,
       )
       );
  }
}