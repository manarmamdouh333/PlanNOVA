import 'package:flutter/material.dart';
import 'goal_chip.dart';
import 'add_goal_dialog.dart';

class GoalSection extends StatelessWidget {
  final List<String> goals;
  final Function(List<String>) onUpdate;

  const GoalSection({
    required this.goals,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    List<String> defaultGoals = [
      "Deep Work",
      "Skill Learning",
      "Fitness",
      "Creative Flow",
      "Admin & Email"
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Goal selection",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 10),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [

            ...defaultGoals.map((goal) => GoalChip(
                  title: goal,
                  selected: goals.contains(goal),
                  onTap: () {
                    List<String> updated = List.from(goals);
                    updated.contains(goal)
                        ? updated.remove(goal)
                        : updated.add(goal);
                    onUpdate(updated);
                  },
                )),

            ActionChip(
              label: Text("+ Add"),
              onPressed: () async {
                String? newGoal =
                    await showAddGoalDialog(context);
                if (newGoal != null) {
                  List<String> updated = List.from(goals);
                  updated.add(newGoal);
                  onUpdate(updated);
                }
              },
            )
          ],
        )
      ],
    );
  }
}