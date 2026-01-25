import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:progress_hub_2/providers/skills_providers.dart';
import '../providers/mastered_screens_providers.dart';
import '../database/db_constants.dart';

class MasteredSkillsScreen extends ConsumerStatefulWidget {
  const MasteredSkillsScreen({super.key});

  @override
  ConsumerState<MasteredSkillsScreen> createState() =>
      _MasteredSkillsScreenState();
}

class _MasteredSkillsScreenState extends ConsumerState<MasteredSkillsScreen> {
  @override
  Widget build(BuildContext context) {
    final masteredSkills = ref.watch(masteredSkillsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        itemCount: masteredSkills.length,
        itemBuilder: (context, index) {
          final masteredSkill = masteredSkills[index];
          return ListTile(
            title: Text(
              masteredSkill['area_name'],
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            subtitle: Text(
              masteredSkill['skill_name'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            trailing: Checkbox(
              value: masteredSkill['is_checked'] == 1,
              onChanged: (bool? value) async {
                if (value == null) return;

                if (value == false) {
                  final ok = await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Mark as not mastered?'),
                      content: const Text(
                        'Are you sure you want to mark this skill as not mastered and continue to walk on it?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Yes, mark'),
                        ),
                      ],
                    ),
                  );

                  if (!context.mounted || ok != true) return;
                  final masteredSkillsNotifier = ref.read(
                    masteredSkillsProvider.notifier,
                  );
                  await masteredSkillsNotifier.toggleMasteredSkill(
                    masteredSkill['id'] as int,
                    false,
                  );
                  ref.invalidate(skillsProvider);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
