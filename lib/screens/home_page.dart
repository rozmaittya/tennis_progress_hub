import 'package:flutter/material.dart';
import 'package:progress_hub_2/utils/gradient_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../screens/goals_screen.dart';
import '../screens/screen_data.dart';
import '../screens/progress_areas_screen.dart';
import '../screens/mastered_skills_screen.dart';
import '../screens/home_content_screen.dart';
import '../widgets/help_dialog.dart';


class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScreen = ref.watch(currentScreenProvider);

    return GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leadingWidth: 36,
            titleSpacing: 8,

            backgroundColor: Colors.transparent,
            title: Text(currentScreen.title ?? 'Main', style: TextStyle(
              fontSize: 16,
            ),),
            leading: IconButton(
                onPressed: () {
                  ref.read(currentScreenProvider.notifier).state = ScreenData(
                      title: 'Tennis Hub',
                      screen: const HomeContentScreen(),
                  );
                  },
                icon: Icon(Icons.home),
                visualDensity: VisualDensity.compact,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.spoke), //sports_martial_arts_rounded),
                tooltip: 'Progress areas/Tennis skills',
                onPressed: () {
                  ref.read(currentScreenProvider.notifier).state = ScreenData(
                      title: 'Skills',
                      screen: const ProgressAreasScreen(),
                  );
                  },
                  ),
              IconButton(
                icon: Icon(Icons.task_alt),
                tooltip: 'game/training goals',
                onPressed: () {
                  ref.read(currentScreenProvider.notifier).state = ScreenData(
                      title: 'Game goals',
                      screen: const GoalsScreen(),
                  );
                }, ),
              IconButton(
                  tooltip: 'Mastered skills',
                  onPressed: () {
                    ref.read(currentScreenProvider.notifier).state = ScreenData(
                        title: 'Mastered skills',
                        screen: const MasteredSkillsScreen(),
                    );
              },
                  icon: Icon(Icons.accessibility_new)),
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'How it works',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const HelpDialog(),
                  );
                },
              ),

            ],
          ),
          body: currentScreen.screen,

        ),
    );
  }
}