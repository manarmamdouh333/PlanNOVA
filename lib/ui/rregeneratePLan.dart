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
  State<RegeneratePlanScreen> createState() =>
      _RegeneratePlanScreenState();
}

class _RegeneratePlanScreenState
    extends State<RegeneratePlanScreen> {

  late List tasks;

  final TextEditingController controller =
      TextEditingController();

  bool loading = false;

  final Color navy = const Color(0xFF2C4356);
  final Color dark = const Color(0xFF1E2A3A);
  final Color teal = const Color(0xFF14B8A6);

  @override
  void initState() {
    super.initState();
    tasks = List.from(widget.currentTasks);
  }

  // ================= ADD TASK =================

  void addTask() {
    if (controller.text.trim().isEmpty) return;

    setState(() {
      tasks.add({
        "title": controller.text.trim(),
        "completed": false,
        "startTime": "--",
        "endTime": "--",
        "duration": 60,
        "type": "General",
      });
    });

    controller.clear();
  }

  // ================= REGENERATE =================

  Future<void> regenerate() async {
    setState(() => loading = true);

    try {

      final resultTasks =
          await widget.onRegenerate(tasks);

      await FirebaseFirestore.instance
          .collection('plans')
          .doc(widget.planId)
          .update({
        "generatedPlan": resultTasks,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Plan regenerated successfully ✨"),
          backgroundColor: Color(0xFF14B8A6),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );

    } finally {

      if (mounted) {
        setState(() => loading = false);
      }
    }
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

          child: Column(

            children: [

              // ================= HEADER =================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                    20, 18, 20, 10),

                child: Row(
                  children: [

                    GestureDetector(
                      onTap: () => Navigator.pop(context),

                      child: Container(
                        padding: const EdgeInsets.all(10),

                        decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(0.12),

                          borderRadius:
                              BorderRadius.circular(16),
                        ),

                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(
                            "Regenerate Plan ✨",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "Update your tasks & generate a smarter schedule",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ================= ADD TASK CARD =================

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18),

                child: Container(
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(28),

                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Row(
                        children: [

                          Icon(
                            Icons.add_task_rounded,
                            color: Color(0xFF14B8A6),
                          ),

                          SizedBox(width: 8),

                          Text(
                            "Add New Task",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      TextField(
                        controller: controller,

                        decoration: InputDecoration(
                          hintText:
                              "What do you want to add?",

                          prefixIcon: const Icon(
                            Icons.task_alt_rounded,
                            color: Color(0xFF14B8A6),
                          ),

                          filled: true,
                          fillColor:
                              const Color(0xFFF8FAFC),

                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        height: 54,

                        child: ElevatedButton.icon(

                          onPressed: addTask,

                          icon: const Icon(
                            Icons.add_rounded,
                          ),

                          label: const Text(
                            "Add Task",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor: navy,
                            foregroundColor: Colors.white,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ================= TITLE =================

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),

                child: Row(
                  children: [

                    const Text(
                      "Current Tasks",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const Spacer(),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color:
                            Colors.white.withOpacity(0.12),

                        borderRadius:
                            BorderRadius.circular(20),
                      ),

                      child: Text(
                        "${tasks.length} Tasks",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ================= TASKS =================

              Expanded(
                child: ListView.builder(

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),

                  itemCount: tasks.length,

                  itemBuilder: (context, i) {

                    final t = tasks[i];

                    return Container(

                      margin:
                          const EdgeInsets.only(bottom: 14),

                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(24),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [

                          // ICON BOX

                          Container(
                            width: 54,
                            height: 54,

                            decoration: BoxDecoration(
                              color: teal.withOpacity(0.12),

                              borderRadius:
                                  BorderRadius.circular(
                                      18),
                            ),

                            child: const Icon(
                              Icons.task_alt_rounded,
                              color: Color(0xFF14B8A6),
                            ),
                          ),

                          const SizedBox(width: 14),

                          // DETAILS

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Text(
                                  t['title'] ?? "",

                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,

                                  children: [

                                    _chip(
                                      Icons.timer_rounded,
                                      "${t['duration'] ?? 60} min",
                                    ),

                                    _chip(
                                      Icons.category_rounded,
                                      t['type'] ??
                                          "General",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // DELETE

                          GestureDetector(
                            onTap: () {
                              setState(() {
                                tasks.removeAt(i);
                              });
                            },

                            child: Container(
                              padding:
                                  const EdgeInsets.all(10),

                              decoration: BoxDecoration(
                                color: Colors.red
                                    .withOpacity(0.1),

                                borderRadius:
                                    BorderRadius.circular(
                                        14),
                              ),

                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ================= BUTTON =================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                    18, 8, 18, 22),

                child: SizedBox(
                  width: double.infinity,
                  height: 64,

                  child: ElevatedButton(

                    onPressed:
                        loading ? null : regenerate,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: navy,
                      elevation: 10,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(22),
                      ),
                    ),

                    child: loading

                        ? const CircularProgressIndicator()

                        : const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [

                              Icon(
                                Icons.auto_awesome_rounded,
                              ),

                              SizedBox(width: 10),

                              Text(
                                "Regenerate Smart Plan",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= CHIP =================

  Widget _chip(
    IconData icon,
    String text,
  ) {

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),

        borderRadius:
            BorderRadius.circular(20),
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