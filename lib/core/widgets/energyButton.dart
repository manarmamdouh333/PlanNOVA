import 'package:flutter/material.dart';

class EnergyChip extends StatelessWidget {
  final String value;
  final String selectedEnergy;
  final Function(String) onChanged;

  const EnergyChip({
    required this.value,
    required this.selectedEnergy,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool selected = selectedEnergy == value;

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