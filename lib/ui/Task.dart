import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plannova/services/firestoreServices.dart';
import 'package:plannova/services/plan_api_service.dart';
import 'package:plannova/ui/HomeOverviewScreen.dart';
import 'package:plannova/ui/finalPlan.dart';

class EnergyScreen extends StatefulWidget {
  final Map<String, String> hoursData;

  const EnergyScreen({
    super.key,
    required this.hoursData,
  });

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen> {
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

  final Color navy = const Color(0xFF2C4356);
  final Color dark = const Color(0xFF1E2A3A);
  final Color teal = const Color(0xFF14B8A6);

  // ================= ADD TASK =================

  void addTask() {
    if (taskController.text.trim().isEmpty ||
        durationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill task and duration"),
        ),
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

  // ================= GENERATE PLAN =================

  Future<void> goNext() async {
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Add at least one task"),
        ),
      );
      return;
    }

    if (uid == null) return;

    setState(() => isLoading = true);

    try {
      final firestore = FirestoreService();

      final planId = await firestore.savePlan(
        userId: uid!,
        days: widget.hoursData,
        energy: "Morning",
        tasks: tasks,
      );

      if (planId == null) {
        throw Exception("Failed to save plan");
      }

      final generatedPlan = await PlanApiService.generatePlan(
        planId: planId,
        energy: "Morning",
        tasks: tasks,
        freeHours: widget.hoursData,
      );

      if (generatedPlan == null) {
        throw Exception("AI generation failed");
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>  const HomeOverviewScreen(),
      
        ),
      );
    } catch (e) {
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

  // ================= DISPOSE =================

  @override
  void dispose() {
    taskController.dispose();
    durationController.dispose();
    super.dispose();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              navy,
              dark,
              teal,
            ],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ================= HEADER =================

                const Text(
                  "Create Smart Tasks ✨",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Build your perfect productive schedule",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 28),

                // ================= MAIN CARD =================

                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // TITLE

                      const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: Color(0xFF14B8A6),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Task Details",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // TASK NAME

                      TextField(
                        controller: taskController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          labelText: "Task Name",
                          prefixIcon: const Icon(
                            Icons.task_alt_rounded,
                            color: Color(0xFF14B8A6),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // DURATION

                      TextField(
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          labelText: "Duration (minutes)",
                          prefixIcon: const Icon(
                            Icons.timer_rounded,
                            color: Color(0xFF3B82F6),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // CATEGORY

                      Row(
                        children: [
                          const Icon(
                            Icons.category_rounded,
                            color: Color(0xFF14B8A6),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Category",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          DropdownButton<String>(
                            value: selectedCategory,
                            underline: const SizedBox(),
                            borderRadius: BorderRadius.circular(18),
                            items: const [
                              "Study",
                              "Gym",
                              "Work",
                              "Health",
                              "Personal",
                              "Meeting"
                            ]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedCategory = val!;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // TASK TYPE

                      const Text(
                        "Task Type",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [

                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedType = "Deep";
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: selectedType == "Deep"
                                      ? const Color(0xFF2C4356)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.psychology_rounded,
                                      color: selectedType == "Deep"
                                          ? Colors.white
                                          : Colors.black54,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Deep Focus",
                                      style: TextStyle(
                                        color: selectedType == "Deep"
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedType = "Light";
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: selectedType == "Light"
                                      ? teal
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.light_mode_rounded,
                                      color: selectedType == "Light"
                                          ? Colors.white
                                          : Colors.black54,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Light Task",
                                      style: TextStyle(
                                        color: selectedType == "Light"
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // SWITCHES

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [

                            SwitchListTile(
                              value: isFlexible,
                              activeColor: teal,
                              title: const Text("Flexible Time"),
                              secondary: const Icon(
                                Icons.schedule_rounded,
                              ),
                              onChanged: (v) {
                                setState(() {
                                  isFlexible = v;
                                });
                              },
                            ),

                            SwitchListTile(
                              value: canSplit,
                              activeColor: teal,
                              title: const Text("Can Split Task"),
                              secondary: const Icon(
                                Icons.call_split_rounded,
                              ),
                              onChanged: (v) {
                                setState(() {
                                  canSplit = v;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ADD TASK BUTTON

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: addTask,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text(
                            "Add Task",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ================= TASKS LIST =================

                if (tasks.isNotEmpty) ...[

                  const Text(
                    "Your Tasks",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 14),

                  ...tasks.asMap().entries.map((entry) {

                    final index = entry.key;
                    final task = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),

                      child: Row(
                        children: [

                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFF14B8A6)
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.task_alt_rounded,
                              color: Color(0xFF14B8A6),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                Text(
                                  task["title"],
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [

                                    _chip(
                                      Icons.timer_rounded,
                                      "${task["duration"]} min",
                                    ),

                                    _chip(
                                      Icons.category_rounded,
                                      task["category"],
                                    ),

                                    _chip(
                                      Icons.psychology_rounded,
                                      task["type"],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              setState(() {
                                tasks.removeAt(index);
                              });
                            },
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 28),

                // ================= GENERATE BUTTON =================

                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : goNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: navy,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),

                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [

                              Icon(Icons.auto_awesome_rounded),

                              SizedBox(width: 10),

                              Text(
                                "Generate My Smart Plan",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= CHIP =================

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            icon,
            size: 14,
            color: Colors.black54,
          ),

          const SizedBox(width: 5),

          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}