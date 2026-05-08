import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String time;
  final bool done;
  final VoidCallback onToggle;

  const TaskCard({
    required this.title,
    required this.time,
    required this.done,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(value: done, onChanged: (_) => onToggle()),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    decoration:
                        done ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
          Text(time),
          SizedBox(height: 10),
          LinearProgressIndicator(value: done ? 1 : 0.3),
        ],
      ),
    );
  }
}