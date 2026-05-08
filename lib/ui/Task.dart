import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plannova/ui/HomeOverviewScreen.dart';
import '../core/widgets/energy_selector.dart';
import 'package:plannova/ui/plan_screen.dart';
import 'package:plannova/services/firestoreServices.dart'; // تأكدي من اسم الملف
import 'package:plannova/services/plan_api_service.dart';

class EnergyScreen extends StatefulWidget {
  final Map<String, String> hoursData;

  const EnergyScreen({super.key, required this.hoursData});

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen> {
  String selectedEnergy = "Morning";
  String selectedType = "Deep";
  String selectedCategory = "Study";
  String selectedPriority = "Medium";

  bool isFlexible = true;
  bool canSplit = true;

  final TextEditingController taskController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  List<Map<String, dynamic>> tasks = [];
  bool isLoading = false;

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF7FAFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  void addTask() {
    if (taskController.text.trim().isEmpty || durationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() {
      tasks.add({
        "title": taskController.text.trim(),
        "duration": int.tryParse(durationController.text.trim()) ?? 60,
        "type": selectedType,
        "category": selectedCategory,
        "priority": selectedPriority,
        "flexible": isFlexible,
        "canSplit": canSplit,
        "status": "pending",
        "completed": false,
        "progress": 0,
      });

      taskController.clear();
      durationController.clear();
    });
  }

  Future<void> goNext() async {
  if (tasks.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Add at least one task")),
    );
    return;
  }

  if (uid == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please login again")),
    );
    return;
  }

  setState(() => isLoading = true);

  try {

    final firestore = FirestoreService();

    // =========================
    // 🔥 SAVE ORIGINAL TASKS
    // =========================

    final planId = await firestore.savePlan(
      userId: uid!,
      days: widget.hoursData,
      energy: selectedEnergy,
      tasks: tasks,
    );

    // =========================
    // 🤖 GENERATE AI PLAN
    // =========================

    final generatedPlan =
        await PlanApiService.generatePlan(
      planId: planId,
      energy: selectedEnergy,
      tasks: tasks,
      freeHours: widget.hoursData,
    );

    if (generatedPlan == null) {
      throw Exception("AI Plan generation failed");
    }

    // =========================
    // 💾 SAVE GENERATED PLAN
    // ========================= 

    await firestore.saveGeneratedPlan(
      planId: planId,
      generatedTasks: generatedPlan,
    );

    if (!mounted) return;

    // =========================
    // 🚀 GO TO PLAN SCREEN
    // =========================

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeOverviewScreen(
      
        ),
        // PlanScreen(
        //   planId: planId,
        //   energy: selectedEnergy,
        // ),
      ),
    );

  } catch (e) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ),
    );

  } finally {

    if (mounted) {
      setState(() => isLoading = false);
    }
  }
}

  @override
  void dispose() {
    taskController.dispose();
    durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C4356), Color(0xFF3A6EA5), Color(0xFFEAF3FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))
                    ],
                  ),
                  child: Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: EnergySelector(
                            selectedEnergy: selectedEnergy,
                            onChanged: (val) => setState(() => selectedEnergy = val),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextField(controller: taskController, decoration: _inputStyle("Task")),
                              const SizedBox(height: 12),
                              TextField(
                                controller: durationController,
                                keyboardType: TextInputType.number,
                                decoration: _inputStyle("Duration (mins)"),
                              ),

                              const SizedBox(height: 12),

                              // Category, Type, Priority...
                              Row(
                                children: [
                                  const Text("Category:"),
                                  const SizedBox(width: 10),
                                  DropdownButton<String>(
                                    value: selectedCategory,
                                    items: const ["Study", "Gym", "Work", "Health", "Personal"]
                                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                        .toList(),
                                    onChanged: (val) => setState(() => selectedCategory = val!),
                                  ),
                                ],
                              ),

                              // باقي الحقول (Type, Priority, Switches)...

                              ElevatedButton(onPressed: addTask, child: const Text("Add Task")),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tasks List
                      if (tasks.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tasks.length,
                          itemBuilder: (_, i) {
                            final task = tasks[i];
                            return Card(
                              child: ListTile(
                                title: Text(task["title"]),
                                subtitle: Text("${task["category"]} • ${task["type"]} • ${task["duration"]} min"),
                                trailing: Text(task["priority"]),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C4356),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: isLoading ? null : goNext,
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Generate My Weekly Plan", style: TextStyle(fontSize: 17)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}