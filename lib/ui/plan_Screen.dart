import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanScreen extends StatefulWidget {
  final String planId;
  final String energy;

  const PlanScreen({
    super.key,
    required this.planId,
    required this.energy,
  });

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  String selectedDay = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Weekly Plan")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("plans")
            .doc(widget.planId)
            .snapshots(),
        builder: (context, snapshot) {
          // 1. التحقق من حالة الاتصال
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. التحقق من وجود أخطاء أو عدم وجود بيانات
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No plan found in database"));
          }

          // 3. قراءة البيانات وتحويلها بشكل آمن (Type Casting)
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final List<dynamic> rawPlan = data?["generatedPlan"] ?? [];
          
          // تحويل الـ List إلى Map<String, dynamic> لضمان استقرار النوع
          final List<Map<String, dynamic>> plan = rawPlan.map((item) {
            return Map<String, dynamic>.from(item as Map);
          }).toList();

          if (plan.isEmpty) {
            return const Center(child: Text("Your plan is empty..."));
          }

          // 4. استخراج الأيام الفريدة
          final days = plan
              .map((e) => e["day"].toString())
              .toSet()
              .toList();

          // تعيين اليوم الافتراضي
          if (selectedDay.isEmpty && days.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => selectedDay = days.first);
              }
            });
          }

          // 5. تصفية المهام حسب اليوم المختار
          final todayTasks = plan.where((e) => e["day"] == selectedDay).toList();

          return Column(
            children: [
              const SizedBox(height: 15),
              
              // عرض مستوى الطاقة
              Text(
                "⚡ Energy: ${widget.energy}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              // شريط الأيام (Days Scroller)
              SizedBox(
                height: 55,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: days.map((day) {
                    final isSelected = day == selectedDay;
                    return GestureDetector(
                      onTap: () => setState(() => selectedDay = day),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 15),
              Text(
                selectedDay,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // قائمة المهام (Task List)
              Expanded(
                child: todayTasks.isEmpty
                    ? const Center(child: Text("No tasks for this day"))
                    : ListView.builder(
                        itemCount: todayTasks.length,
                        itemBuilder: (context, i) {
                          final task = todayTasks[i];

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                              border: Border(
                                left: BorderSide(
                                  // التفاعل مع نوع المهمة كما هو في الصورة
                                  color: task["type"] == "Deep" ? Colors.red : Colors.green,
                                  width: 5,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // اسم المهمة (استخدام "task" حرف صغير كما في Firestore)
                                Text(
                                  task["task"]?.toString() ?? "No Title",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                
                                // الوقت
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text(
                                      "${task["startTime"] ?? "--"} → ${task["endTime"] ?? "--"}",
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // الأوسمة (Badges)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _badge("⏳ ${task["duration"] ?? "0"} min"),
                                    _badge("🔥 ${task["type"] ?? "General"}"),
                                    _badge(task["flexible"] == true ? "Flexible" : "Fixed"),
                                    if (task["canSplit"] == true) _badge("Splitable"),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ودجت الوسام المصمم بشكل أفضل
  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600),
      ),
    );
  }
}