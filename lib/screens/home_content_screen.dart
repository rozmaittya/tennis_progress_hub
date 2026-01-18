import '../providers/tips_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeContentScreen extends ConsumerWidget {
  const HomeContentScreen({super.key});

  String formatAreaKey(String key) {
    return key
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tip = ref.watch(tipProvider);

    return ListView(
     padding: const EdgeInsets.all(16),
     children: [
       const Text('Welcome to Tennis Hub 👋\n\n'
           'Focus on a few skills, train with intention, \n'
           'and track your progress step by step.',
       style: TextStyle(fontSize: 16),),

       const SizedBox(height: 26),

       Card(
         color: Colors.white.withOpacity(0.15),
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
                  'Tip of the Day • ${formatAreaKey(tip.areaKey)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 8),

                //Tip text
                Text(
                  tip.text.isEmpty ? 'No tip available.' : tip.text,
                  style: const TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 12,),

                Row(
                  children: [
                    TextButton.icon(
                        onPressed: () => ref.read(tipProvider.notifier).nextTip(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Next tip'),

                    ),
                  ],
                )
              ],
            ),
         ),

       ),
     ],
    );
  }
}

