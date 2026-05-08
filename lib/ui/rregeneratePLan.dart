import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegeneratePlanScreen extends StatefulWidget {
  final String planId;
  final List currentTasks;
  final Future<List> Function(List tasks) onRegenerate;

  const RegeneratePlanScreen({
    super.key,
    required this.planId,
    required this.currentTasks,
    required this.onRegenerate,
  });

  @override
  State<RegeneratePlanScreen> createState() => _RegeneratePlanScreenState();
}

class _RegeneratePlanScreenState extends State<RegeneratePlanScreen> {
  late List tasks;
  final TextEditingController controller = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    tasks = List.from(widget.currentTasks);
  }

  void addTask() {
    if (controller.text.isEmpty) return;

    tasks.add({
      "title": controller.text,
      "completed": false,
      "startTime": "--",
      "endTime": "--",
    });

    controller.clear();
    setState(() {});
  }

  Future<void> regenerate() async {
    setState(() => loading = true);

    final resultTasks = await widget.onRegenerate(tasks);

    await FirebaseFirestore.instance
        .collection('plans')
        .doc(widget.planId)
        .update({
      "generatedPlan": resultTasks,
    });

    setState(() => loading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2A3A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2A3A),
        title: const Text("Regenerate Plan"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          const Text(
            "Current Tasks",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, i) {
                final t = tasks[i];

                return Card(
                  child: ListTile(
                    title: Text(t['title'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() => tasks.removeAt(i));
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                filled: true,
                hintText: "Add new task",
              ),
            ),
          ),

          ElevatedButton(
            onPressed: addTask,
            child: const Text("Add Task"),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B8A6),
                padding: const EdgeInsets.all(16),
              ),
              onPressed: loading ? null : regenerate,
              child: Text(
                loading ? "Regenerating..." : "Regenerate Plan",
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}