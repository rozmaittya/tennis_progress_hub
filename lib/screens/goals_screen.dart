import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:progress_hub_2/utils/gradient_background.dart';
import '../providers/goals_providers.dart';
import '../widgets/tennis_ball_button.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);

    // if(goals.isEmpty) {
    //   return const Center(child: Text('No checked goals.\nGo to Progress areas \nand mark the required skiils \nas goals'),);
    // }

    return Scaffold(
          backgroundColor: Colors.transparent,
          body:
        ListView.builder(
      itemCount: goals.length,
        itemBuilder: (context, index) {
        final goal = goals[index];
        return ListTile(
          leading: IconButton(onPressed: () {},
            icon: Icon(Icons.check_box), color: Colors.green,),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                goal['area_name'],
                style: TextStyle(
                    fontSize: 14),
              ),
              Text(
                  '    ' + goal['item_name'] ?? '',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                  ),

              ),
          ],)
        );

        }),
    floatingActionButton: TennisBallButton(onPressed: () {

    }
    ),
    );
  }
}
