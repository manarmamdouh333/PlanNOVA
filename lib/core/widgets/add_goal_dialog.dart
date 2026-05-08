import 'package:flutter/material.dart';

Future<String?> showAddGoalDialog(BuildContext context) async {
  TextEditingController controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Add Goal"),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: "Goal name"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, controller.text);
          },
          child: Text("Add"),
        ),
      ],
    ),
  );
}