import 'package:flutter/material.dart';

class GoalChip extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const GoalChip({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(title),
      selected: selected,
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
      ),
      onSelected: (_) => onTap(),
    );
  }
}