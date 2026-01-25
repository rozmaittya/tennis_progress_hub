import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progress_hub_2/database/db_constants.dart';
import '../utils/edit_item_dialog.dart';
import '../providers/skills_providers.dart';
import '../providers/database_provider.dart';
import '../providers/mastered_screens_providers.dart';
import '../providers/goals_providers.dart';
import '../widgets/tennis_ball_button.dart';
import '../utils/gradient_background.dart';
import '../database/db_constants.dart';

class SkillsScreen extends ConsumerStatefulWidget {
  final int areaId;
  final String areaName;

  const SkillsScreen({
    super.key,
    required this.areaId,
    required this.areaName,
  });

  @override
  ConsumerState<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends ConsumerState<SkillsScreen> {
  Future<void> _toggleSkill(int id, bool isChecked) async {
    await ref
        .read(skillsProvider(widget.areaId).notifier)
        .toggleSkill(id, isChecked);
  }

  Future<void> _editSkill(int id, String currentName) async {
    final db = ref.read(databaseProvider).value;
    if (db == null) return;

    await editSkillDialog(
      context: context,
      db: db,
      tableName: SkillTable.table,
      id: id,
      currentName: currentName,
      onUpdated: () {
        ref.read(skillsProvider(widget.areaId).notifier).loadSkills();
        ref.invalidate(goalsProvider);
      },
    );
  }

  Future<void> _showAddSkillDialog() async {
    String skillName = '';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add new skill'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Input new skill name'),
            onChanged: (value) => skillName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (skillName.trim().isNotEmpty) {
                  Navigator.of(dialogContext).pop(skillName);
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
          .read(skillsProvider(widget.areaId).notifier)
          .addSkill(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skills = ref.watch(skillsProvider(widget.areaId));

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
          itemCount: skills.length,
          itemBuilder: (itemContext, index) {
            final skill = skills[index];

            return ListTile(
              title: Text(
                (skill[SkillTable.name] ?? '').toString(),
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
                value: skill[SkillTable.isChecked] == 1,
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

                  await _toggleSkill(skill[SkillTable.id] as int, value);
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
                  await _editSkill(
                    skill[SkillTable.id] as int,
                    (skill[SkillTable.name] ?? '').toString(),
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
                        .read(skillsProvider(widget.areaId).notifier)
                        .deleteSkill(skill[SkillTable.id] as int);
                    await ref
                        .read(skillsProvider(widget.areaId).notifier)
                        .loadSkills();
                  }
                }
              },
            );
          },
        ),
        floatingActionButton: TennisBallButton(onPressed: _showAddSkillDialog),
      ),
    );
  }
}
