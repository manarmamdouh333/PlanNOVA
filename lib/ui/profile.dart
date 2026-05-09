import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:plannova/ui/login.dart';
import 'package:plannova/ui/rregeneratePLan.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
              ? const Center(
                  child: Text("No user found",
                      style: TextStyle(color: Colors.white)),
                )
              : FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .get(),
                  builder: (context, userSnap) {
                    if (!userSnap.hasData) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: Colors.white));
                    }

                    final userData =
                        userSnap.data!.data() as Map<String, dynamic>? ?? {};

                    final lastPlanId = userData['lastPlanId'];

                    return StreamBuilder<DocumentSnapshot>(
                      stream: lastPlanId != null
                          ? FirebaseFirestore.instance
                              .collection('plans')
                              .doc(lastPlanId)
                              .snapshots()
                          : null,
                      builder: (context, planSnap) {
                        List tasks = [];

                        if (planSnap.hasData && planSnap.data!.exists) {
                          final data = planSnap.data!.data()
                              as Map<String, dynamic>;
                          tasks = data['generatedPlan'] ?? [];
                        }

                        final total = tasks.length;
                        final done = tasks
                            .where((t) => t['completed'] == true)
                            .length;
                        final progress =
                            total == 0 ? 0.0 : done / total;

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // ================= PROFILE =================
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Column(
                                  children: [
                                    const CircleAvatar(
                                      radius: 58,
                                      backgroundColor: Colors.white,
                                      child: Icon(Icons.person,
                                          size: 75,
                                          color: Color(0xFF2C4356)),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      userData['name'] ?? "Welcome",
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      userData['email'] ?? "",
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // ================= STATS =================
                              Row(
                                children: [
                                  _infoCard(
                                      "Energy",
                                      userData['profile']?['energy'] ??
                                          "Not Set",
                                      Icons.bolt),
                                  const SizedBox(width: 12),
                                  _infoCard(
                                      "Plan Type",
                                      userData['profile']?['planType'] ??
                                          "Balanced",
                                      Icons.style),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // ================= PROGRESS =================
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      "Weekly Progress",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 18),

                                    CircularPercentIndicator(
                                      radius: 82,
                                      lineWidth: 14,
                                      percent: progress,
                                      center: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "${(progress * 100).toInt()}%",
                                            style: const TextStyle(
                                                fontSize: 34,
                                                fontWeight:
                                                    FontWeight.bold),
                                          ),
                                          const Text("Completed"),
                                        ],
                                      ),
                                      progressColor:
                                          const Color(0xFF14B8A6),
                                    ),

                                    const SizedBox(height: 14),
                                    Text(
                                      "$done of $total tasks completed",
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),

                              // ================= ACTIONS =================

                              _actionButton(
                                Icons.refresh_rounded,
                                "Regenerate Plan",
                                () {
                                Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => RegeneratePlanScreen(
      planId: lastPlanId ?? "",
      currentTasks: tasks,
      onRegenerate: (tasks) async {
        final response = await http.post(
          Uri.parse("http://localhost:5000/generate"),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "tasks": tasks,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // المفروض الـ API يرجّع list
          return data["generatedPlan"] ?? tasks;
        } else {
          throw Exception("Failed to regenerate plan");
        }
      },
    ),
  ),
);
                                },
                              ),

                              _actionButton(
                                Icons.settings_rounded,
                                "Settings",
                                () {},
                              ),

                            _actionButton(
  Icons.logout_rounded,
  "Logout",
  () async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  },
  color: Colors.redAccent,
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

  // ================= CARD =================
  Widget _infoCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF14B8A6)),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title),
          ],
        ),
      ),
    );
  }

  // ================= BUTTON =================
  Widget _actionButton(
      IconData icon, String text, VoidCallback onTap,
      {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        tileColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: Icon(icon,
            color: color ?? const Color(0xFF14B8A6)),
        title: Text(text),
        onTap: onTap,
      ),
    );
  }
}