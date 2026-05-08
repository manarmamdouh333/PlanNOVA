import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../core/colors.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

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
          child: uid == null
              ? const Center(child: Text("No user logged in"))
              : FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .get(),
                  builder: (context, userSnap) {
                    if (!userSnap.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    final userData =
                        userSnap.data!.data() as Map<String, dynamic>?;
                    final lastPlanId = userData?['lastPlanId'];

                    if (lastPlanId == null) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.celebration,
                                size: 90, color: Colors.white70),
                            SizedBox(height: 16),
                            Text(
                              "No plan yet",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('plans')
                          .doc(lastPlanId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          );
                        }

                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        final List tasks = data['generatedPlan'] ?? [];

                        final total = tasks.length;
                        final completed =
                            tasks.where((t) => t['completed'] == true).length;
                        final pending = total - completed;
                        final progress =
                            total == 0 ? 0.0 : completed / total;

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // ================= HERO =================
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32,
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      "Your Weekly Progress",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    CircularPercentIndicator(
                                      radius: 120,
                                      lineWidth: 16,
                                      animation: true,
                                      percent: progress,
                                      center: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "${(progress * 100).toInt()}%",
                                            style: const TextStyle(
                                              fontSize: 44,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const Text(
                                            "ACHIEVED",
                                            style: TextStyle(
                                              color: Colors.white,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      progressColor: Colors.white,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.2),
                                      circularStrokeCap:
                                          CircularStrokeCap.round,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // ================= STATS =================
                              Row(
                                children: [
                                  _buildModernStatCard(
                                    "Total",
                                    total.toString(),
                                    Icons.list_alt_rounded,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildModernStatCard(
                                    "Done",
                                    completed.toString(),
                                    Icons.check_circle_rounded,
                                    Colors.greenAccent,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildModernStatCard(
                                    "Left",
                                    pending.toString(),
                                    Icons.timelapse_rounded,
                                    Colors.orangeAccent,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // ================= TASKS =================
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Tasks Overview",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: tasks.length,
                                      itemBuilder: (context, i) {
                                        final t = tasks[i];
                                        final isDone =
                                            t['completed'] == true;

                                        return Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 12),
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: isDone
                                                ? const Color(0xFFECFDF5)
                                                : const Color(0xFFF8FAFC),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isDone
                                                  ? Colors.green.withOpacity(0.3)
                                                  : Colors.grey.withOpacity(0.1),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                isDone
                                                    ? Icons.check_circle
                                                    : Icons.circle_outlined,
                                                color: isDone
                                                    ? Colors.green
                                                    : Colors.grey,
                                                size: 26,
                                              ),
                                              const SizedBox(width: 12),

                                              Expanded(
                                                child: Text(
                                                  t['title'] ??
                                                      t['task'] ??
                                                      '',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                    decoration: isDone
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : null,
                                                    color: isDone
                                                        ? Colors.grey
                                                        : Colors.black87,
                                                  ),
                                                ),
                                              ),

                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: t['type'] == "Deep"
                                                      ? Colors.red
                                                          .withOpacity(0.1)
                                                      : Colors.teal
                                                          .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20),
                                                ),
                                                child: Text(
                                                  t['type'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color:
                                                        t['type'] == "Deep"
                                                            ? Colors.red
                                                            : Colors.teal,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }

  // ================= STATS CARD =================
  Widget _buildModernStatCard(
    String title,
    String value,
    IconData icon, [
    Color? color,
  ]) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: color ?? AppColors.darkPrimary, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}