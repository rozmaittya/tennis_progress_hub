import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:progress_hub_2/utils/gradient_background.dart';
import '../providers/goals_providers.dart';
import '../widgets/tennis_ball_button.dart';
import '../utils/add_edit_goal_dialog.dart';
import '../utils/show_context_menu.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}
 class _GoalsScreenState extends ConsumerState<GoalsScreen> {

  Offset _tapPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          return GestureDetector(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, 3),
                    color: Colors.black12,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // left accent line
                  Container(
                    width: 6,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      title: Text(
                        goal['area_name'],
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          goal['item_name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                     // trailing: const Icon(Icons.more_vert),
                    ),
                  ),
                ],
              ),
            ),

            // child: ListTile(
            //   leading: IconButton(
            //     onPressed: () {},
            //     icon: Icon(Icons.check_box),
            //     color: Colors.green,
            //   ),
            //   title: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Text(goal['area_name'], style: TextStyle(fontSize: 14)),
            //       Text(
            //         '    ' + (goal['item_name'] ?? ''),
            //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            //       ),
            //     ],
            //   ),
            // ),
            onTapDown: (details) {
              _tapPosition = details.globalPosition;
            },
            onLongPress: () async {
              final selected = await showContextMenu(
                context: context,
                tapPosition: _tapPosition,
                items: const [
                  PopupMenuItem(value: 'edit', child: Text('edit')),
                  PopupMenuItem(value: 'achieved', child: Text('achieved')),
                  PopupMenuItem(value: 'delete', child: Text('delete')),
                ],
              );

              if (!mounted || selected == null) return;

              final goalsNotifier = ref.read(goalsProvider.notifier);
              final goalId = goal['id'] as int;

              switch (selected) {
                case 'edit':
                  final itemId = goal['item_id'] as int?;
                  await showAddEditGoalDialog(
                      context: context,
                      ref: ref,
                      existingGoalId: goalId,
                      existingItemId: itemId,
                  );
                  break;

                case 'achieved':
                  await goalsNotifier.toggleGoal(goalId, true);
                  await goalsNotifier.loadGoals();
                  break;

                case 'delete':
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete goal?'),
                      content: const Text('Are you sure you want to delete this goal?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))
                      ],
                    ),
                  );

                  if (ok == true) {
                    await goalsNotifier.deleteGoal(goalId);
                    await goalsNotifier.loadGoals();
                  }
                  break;
              }
            },
          );
        },
      ),
      floatingActionButton: TennisBallButton(
        onPressed: () {
          showAddEditGoalDialog(context: context, ref: ref);
        },
      ),
    );
  }
}
