// lib/screens/free_hours_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plannova/core/colors.dart';
import 'package:plannova/ui/Task.dart';
import '../core/widgets/freee_hours_field.dart';

class FreeHoursScreen extends StatefulWidget {
  const FreeHoursScreen({super.key});

  @override
  State<FreeHoursScreen> createState() => _FreeHoursScreenState();
}

class _FreeHoursScreenState extends State<FreeHoursScreen> {
  final Map<String, TextEditingController> hoursControllers = {
    "Monday": TextEditingController(),
    "Tuesday": TextEditingController(),
    "Wednesday": TextEditingController(),
    "Thursday": TextEditingController(),
    "Friday": TextEditingController(),
    "Saturday": TextEditingController(),
    "Sunday": TextEditingController(),
  };

  bool isLoading = false;

  Future<void> _saveFreeHoursAndGoNext() async {
    setState(() => isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Prepare data
    final Map<String, String> hoursData = hoursControllers.map(
      (key, controller) => MapEntry(key, controller.text.trim()),
    );

    // Check if at least one day has data
    bool hasData = hoursData.values.any((v) => v.isNotEmpty);

    if (!hasData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter free hours for at least one day")),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      // Save to Firestore under user
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'freeHours': hoursData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EnergyScreen(hoursData: hoursData),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    for (var controller in hoursControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [  AppColors.darkPrimary,
              Color(0xFFBAE6FD),
              Color(0xFF7DD3FC),
            ],
        
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "When are you free?",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Enter your available hours per day",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),

                      const SizedBox(height: 32),

                      ...hoursControllers.entries.map((entry) {
                        return FreeHoursField(
                          day: entry.key,
                          controller: entry.value,
                        );
                      }).toList(),

                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _saveFreeHoursAndGoNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Next Step",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                                  
                                  ),
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