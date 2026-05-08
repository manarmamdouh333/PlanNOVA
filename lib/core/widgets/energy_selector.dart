import 'package:flutter/material.dart';

class EnergySelector extends StatelessWidget {
  final String selectedEnergy;
  final Function(String) onChanged;

  const EnergySelector({
    super.key,
    required this.selectedEnergy,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Energy type",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(child: _chip(context, "Morning")),
            const SizedBox(width: 1),
            Expanded(child: _chip(context, "Night")),
          ],
        )
      ],
    );
  }

  Widget _chip(BuildContext context, String value) {
    final bool selected = selectedEnergy == value;

    return ChoiceChip(
      label: Text(value),
      selected: selected,
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
      ),
      onSelected: (_) => onChanged(value),
    );
  }
}