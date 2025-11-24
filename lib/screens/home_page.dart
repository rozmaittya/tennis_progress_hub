import 'package:flutter/material.dart';
import 'package:progress_hub_2/utils/gradient_background.dart';
import 'progress_areas_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../screens/goals_screen.dart';
import '../screens/screen_data.dart';
import '../screens/progress_areas_screen.dart';
import '../widgets/tennis_ball_button.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScreen = ref.watch(currentScreenProvider);

    return GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(currentScreen.title ?? 'Main', style: TextStyle(
              fontSize: 16,
            ),),
            leading: IconButton(
                onPressed: () {
                  ref.read(currentScreenProvider.notifier).state = ScreenData(
                      title: 'Tennis hub',
                      screen: const Center(child: Text('Let\'s progress!\n\nAdd new skills\nor mark 1-3 goals\nfor game or training',)),
                  );
                  },
                icon: Icon(Icons.home)),
            actions: [
              IconButton(
                icon: Icon(Icons.spoke),
                tooltip: 'Progress ares/Tennis skills',  
                onPressed: () {
                  ref.read(currentScreenProvider.notifier).state = ScreenData(
                      title: 'Skills groups',
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
                  onPressed: () {

              },
                  icon: Icon(Icons.accessibility_new)),
            ],
          ),
          body: currentScreen.screen,

        ),
    );
  }
}