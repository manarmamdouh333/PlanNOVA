import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plannova/ui/finalPlan.dart';
import 'package:plannova/ui/profile.dart';
import 'package:plannova/ui/progress.dart';

class HomeOverviewScreen extends StatefulWidget {
  const HomeOverviewScreen({super.key});

  @override
  State<HomeOverviewScreen> createState() => _HomeOverviewScreenState();
}

class _HomeOverviewScreenState extends State<HomeOverviewScreen> {
  int currentIndex = 0;

  String? lastPlanId;
  String userEnergy = "Morning";

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        lastPlanId = doc.data()?['lastPlanId'];
        userEnergy = doc.data()?['energy'] ?? "Morning";
      });
    }
  }

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
              Color(0xFF1E2A3A),
              Color(0xFF14B8A6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (currentIndex == 0) _buildHeader(),
              Expanded(child: _buildCurrentScreen()),
            ],
          ),
        ),
      ),

      // Bottom Navigation - Modern & Beautiful
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ===================== HEADER =====================
  Widget _buildHeader() {
    final today = DateTime.now();
    final dateStr = "${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Good Morning,",
                style: TextStyle(fontSize: 22, color: Colors.white70),
              ),
              const Text(
                "Let's crush today ✨",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: const Color(0xFF2C4356), size: 30),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== Bottom Navigation =====================
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 25,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_rounded, "Home", 0),
            _navItem(Icons.calendar_month_rounded, "Plan", 1),
            _navItem(Icons.show_chart_rounded, "Progress", 2),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected ? const Color(0xFF14B8A6) : Colors.grey.shade400,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF14B8A6) : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== Screen Switch =====================
  Widget _buildCurrentScreen() {
    switch (currentIndex) {
      case 0:
        return _buildTodayTasks();
      case 1:
        return lastPlanId == null
            ? const Center(
                child: Text(
                  "No plan yet\nStart by adding tasks",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              )
            : Finalplan(planId: lastPlanId!, energy: userEnergy);
      case 2:
        return const ProgressScreen();
      default:
        return const SizedBox();
    }
  }

  // ===================== TODAY TASKS =====================
  Widget _buildTodayTasks() {
    final todayName = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        [DateTime.now().weekday % 7];

    if (lastPlanId == null) {
      return const Center(child: Text("No plan yet", style: TextStyle(color: Colors.white70)));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('plans').doc(lastPlanId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final List allTasks = data['generatedPlan'] ?? [];

        final todayTasks = allTasks.where((t) => t['day'] == todayName).toList();

        if (todayTasks.isEmpty) {
          return const Center(
            child: Text("No tasks for today 🎉", style: TextStyle(color: Colors.white70, fontSize: 18)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: todayTasks.length,
          itemBuilder: (context, i) {
            final t = todayTasks[i];
            final completed = t['completed'] ?? false;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(18),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14B8A6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.task_alt, color: Color(0xFF14B8A6)),
                ),
                title: Text(
                  t['title'] ?? '',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    decoration: completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  "${t['category'] ?? ''} • ${t['duration']} min",
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Checkbox(
                  value: completed,
                  activeColor: const Color(0xFF14B8A6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onChanged: (_) async {
                    final newValue = !completed;
                    final updatedTasks = List.from(allTasks);
                    final index = allTasks.indexOf(t);

                    updatedTasks[index] = {...t, "completed": newValue};

                    await FirebaseFirestore.instance
                        .collection('plans')
                        .doc(lastPlanId!)
                        .update({"generatedPlan": updatedTasks});
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}