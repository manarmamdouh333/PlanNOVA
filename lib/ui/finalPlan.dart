import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/colors.dart';

class Finalplan extends StatefulWidget {
  final String planId;
  final String energy;

  const Finalplan({
    super.key,
    required this.planId,
    required this.energy,
  });

  @override
  State<Finalplan> createState() => _FinalplanState();
}

class _FinalplanState extends State<Finalplan> {
  String selectedDay = "";

  final Color iconBlue = const Color(0xFF3B82F6);
  final Color iconGreen = const Color(0xFF10B981);
  final Color iconOrange = const Color(0xFFF59E0B);
  final Color iconPurple = const Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
            Color(0xFF2C4356),
                          Color(0xFF14B8A6),
            ],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('plans')
                .doc(widget.planId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (!snapshot.data!.exists) {
                return const Center(
                  child: Text(
                    "No plan found",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final data =
                  snapshot.data!.data() as Map<String, dynamic>;

              final List rawTasks =
                  data['generatedPlan'] ?? data['tasks'] ?? [];

              final List<Map<String, dynamic>> allTasks =
                  rawTasks.map((e) => Map<String, dynamic>.from(e)).toList();

              if (allTasks.isEmpty) {
                return const Center(
                  child: Text(
                    "No tasks available",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final Set<String> daysSet = {};
              for (var t in allTasks) {
                if (t['day'] != null) daysSet.add(t['day'].toString());
              }

              final List<String> days = daysSet.toList()
                ..sort((a, b) => [
                      "Sunday",
                      "Monday",
                      "Tuesday",
                      "Wednesday",
                      "Thursday",
                      "Friday",
                      "Saturday"
                    ]
                        .indexOf(a)
                        .compareTo([
                      "Sunday",
                      "Monday",
                      "Tuesday",
                      "Wednesday",
                      "Thursday",
                      "Friday",
                      "Saturday"
                    ].indexOf(b)));

              if (selectedDay.isEmpty && days.isNotEmpty) {
                selectedDay = days.first;
              }

              final todayTasks =
                  allTasks.where((t) => t['day'] == selectedDay).toList();

              return Column(
                children: [
                  // HEADER (no selected day here anymore)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "My Weekly Plan",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // DAYS
                  SizedBox(
                    height: 68,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        final day = days[index];
                        final isSelected = day == selectedDay;

                        return GestureDetector(
                          onTap: () => setState(() => selectedDay = day),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.darkPrimary
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 👇 NEW CLEAN SECTION HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.today, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          selectedDay,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // TASKS
                  Expanded(
                    child: todayTasks.isEmpty
                        ? const Center(
                            child: Text(
                              "No tasks for this day",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: todayTasks.length,
                            itemBuilder: (context, index) {
                              final task = todayTasks[index];
                              final completed = task['completed'] ?? false;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // TIME
                                      SizedBox(
                                        width: 80,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.play_circle_fill,
                                                    size: 16, color: iconBlue),
                                                const SizedBox(width: 4),
                                                Text(
                                                  task['startTime'] ?? '--',
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 2),
                                              child: Icon(Icons.arrow_downward,
                                                  size: 14, color: Colors.grey),
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.stop_circle,
                                                    size: 16, color: iconOrange),
                                                const SizedBox(width: 4),
                                                Text(
                                                  task['endTime'] ?? '--',
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 14),

                                      // DETAILS
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task['title'] ?? task['task'] ?? '',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                decoration: completed
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                                color: completed
                                                    ? Colors.grey
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 6,
                                              children: [
                                                _badgeIcon(Icons.timer_outlined,
                                                    "${task['duration']} min",
                                                    iconBlue),
                                                _badgeIcon(Icons.category_outlined,
                                                    task['type'] ?? 'General',
                                                    iconPurple),
                                                _badgeIcon(Icons.folder_outlined,
                                                    task['category'] ?? '',
                                                    iconGreen),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      Checkbox(
                                        value: completed,
                                        activeColor: iconBlue,
                                        onChanged: (_) async {
                                          final newValue = !completed;
                                          final updatedTasks = List.from(allTasks);
                                          final idx = allTasks.indexOf(task);

                                          updatedTasks[idx] = {
                                            ...task,
                                            "completed": newValue,
                                            "status": newValue ? "completed" : "pending",
                                            "progress": newValue ? 100 : 0,
                                          };

                                          await FirebaseFirestore.instance
                                              .collection('plans')
                                              .doc(widget.planId)
                                              .update({"generatedPlan": updatedTasks});
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _badgeIcon(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}