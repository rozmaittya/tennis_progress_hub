import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../providers/skills_providers.dart';
import '../providers/tips_providers.dart';
import '../providers/skill_areas_providers.dart';

class HomeContentScreen extends ConsumerWidget {
  const HomeContentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tip = ref.watch(tipProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Welcome to Tennis Hub 👋\n\n'
          'Focus on a few skills, train with intention, \n'
          'and track your progress step by step.',
          style: TextStyle(fontSize: 16),
        ),

        const SizedBox(height: 26),

        GestureDetector(
          onLongPress: () {
            Clipboard.setData(
              ClipboardData(
                text: '''
            ${tip.title}
            ${tip.text}
            '''),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tip copied to clipboard')),
            );
          },
          child: Card(
            color: Colors.white.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Tip title
                  Text(
                    tip.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  //Tip text
                  Text(
                    tip.text.isEmpty ? 'No tip available.' : tip.text,
                    style: const TextStyle(fontSize: 20),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: () async {
                      final tip = ref.read(tipProvider);

                      if (tip.text.isEmpty || tip.area.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No tip to add')),
                        );
                        return;
                      }

                      final areaId = ref.read(areaIdByNameProvider(tip.area));

                      if (areaId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Skills group "${tip.area}" not found',
                            ),
                          ),
                        );
                        return;
                      }

                      await ref
                          .read(skillsProvider(areaId).notifier)
                          .addSkill(tip.text);

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tip added to skills')),
                      );
                    },

                    icon: const Icon(Icons.add),
                    label: const Text('Add Tip to Skills'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      side: BorderSide(
                        color: Colors.black87.withValues(alpha: 0.6),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () =>
                            ref.read(tipProvider.notifier).nextTip(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Next tip'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.black38,
                          elevation: 0,
                          side: BorderSide(
                            color: Colors.black38.withValues(alpha: 0.4),
                          ),
                        ),
                      ),

                      SizedBox(width: 10),

                      ElevatedButton.icon(
                        onPressed: () =>
                            ref.read(tipProvider.notifier).backToTipOfTheDay(),
                        icon: const Icon(Icons.arrow_back_outlined),
                        label: const Text('Tip of the Day'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.black38,
                          elevation: 0,
                          side: BorderSide(
                            color: Colors.black38.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
