// lib/screens/setup_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plannova/core/colors.dart';
import 'package:plannova/ui/FreeHours.dart';
import 'package:plannova/ui/home_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();

  String selectedEnergy = "Morning";
  String selectedPlanType = "Balanced";

  final List<String> energyLevels = ["Morning", "Afternoon", "Evening", "Night"];
  final List<String> planTypes = ["Balanced", "Deep Focus", "Relaxed", "Productivity"];

  TimeOfDay wakeTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay sleepTime = const TimeOfDay(hour: 23, minute: 0);

  bool isLoading = false;

  Future<void> _saveUserProfile() async {
    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'profile': {
          'energy': selectedEnergy,
          'planType': selectedPlanType,
          'wakeTime': "${wakeTime.hour}:${wakeTime.minute.toString().padLeft(2, '0')}",
          'sleepTime': "${sleepTime.hour}:${sleepTime.minute.toString().padLeft(2, '0')}",
          'setupCompleted': true,
          'createdAt': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FreeHoursScreen()),
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
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient Background on Scaffold
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
        // Light blue
            AppColors.darkPrimary,
              Color(0xFFBAE6FD),
              Color(0xFF7DD3FC),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 35,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Let's make it personal ✨",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Help us understand your rhythm so AI can create the perfect plan",
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),

                        const SizedBox(height: 40),

                        const Text("Peak Energy Time", 
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: energyLevels.map((level) {
                            final isSelected = selectedEnergy == level;
                            return ChoiceChip(
                              label: Text(level),
                              selected: isSelected,
                              onSelected: (_) => setState(() => selectedEnergy = level),
                              selectedColor: AppColors.darkPrimary,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 32),

                        const Text("Preferred Plan Style", 
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: planTypes.map((type) {
                            final isSelected = selectedPlanType == type;
                            return ChoiceChip(
                              label: Text(type),
                              selected: isSelected,
                              onSelected: (_) => setState(() => selectedPlanType = type),
                              selectedColor: const Color(0xFF14B8A6),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 32),

                        const Text("Wake Up Time", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.wb_sunny_outlined, color:Colors.amber),
                          title: Text(wakeTime.format(context), 
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                          onTap: () async {
                            final time = await showTimePicker(context: context, initialTime: wakeTime);
                            if (time != null) setState(() => wakeTime = time);
                          },
                        ),

                        const Divider(height: 32),

                        const Text("Sleep Time", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.nightlight_round, color: Color.fromARGB(255, 48, 50, 53)),
                          title: Text(sleepTime.format(context), 
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                          onTap: () async {
                            final time = await showTimePicker(context: context, initialTime: sleepTime);
                            if (time != null) setState(() => sleepTime = time);
                          },
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _saveUserProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:AppColors.darkPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    "Continue to Dashboard",
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
      ),
    );
  }
}