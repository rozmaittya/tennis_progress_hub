import 'package:flutter/material.dart';
import 'package:progress_hub_2/providers/goals_providers.dart';
import '../providers/skill_areas_providers.dart';
import '../screens/skills_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/tennis_ball_button.dart';
import '../providers/mastered_screens_providers.dart';
import '../database/db_constants.dart';

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
        await ref.read(areasProvider.notifier).editArea(id, result);
        ref.invalidate(masteredSkillsProvider);
        ref.invalidate(goalsProvider);

      }
    });
  }

  Future<void> _showAddSkillDialog() async {
    String skillName = '';
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
              skillName = value;
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
                if (skillName
                    .trim()
                    .isNotEmpty) {
                  Navigator.of(context).pop(skillName);
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
        await ref.read(areasProvider.notifier).addArea(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final skills = ref.watch(areasProvider);

     return  Scaffold(
       backgroundColor: Colors.transparent,
       body:
       ListView.builder(
        itemCount: skills.length,
        itemBuilder: (context, index) {
          final skill = skills[index];
          return ListTile(
            leading: Icon(Icons.sports_tennis),
            title: Text(skill[SkillTable.name], style:
              TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SkillsScreen(
                        areaId: skill[SkillTable.id],
                        areaName: skill[SkillTable.name],
                      ),
                ),
              );
            },
            onLongPress: () =>
                _editItem(skill[SkillTable.id], skill[SkillTable.name]),
          );
        },
      ),

       floatingActionButton: TennisBallButton(
        onPressed: _showAddSkillDialog,
       )
       );
  }
}