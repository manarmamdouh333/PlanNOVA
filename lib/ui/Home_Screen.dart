import 'package:flutter/material.dart';
import 'package:plannova/core/widgets/freee_hours_field.dart';
import 'package:plannova/ui/Task.dart';

// import 'energy_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _DaysScreenState();
}

class _DaysScreenState extends State<HomeScreen> {
  final Map<String, TextEditingController> hoursControllers = {
    "Monday": TextEditingController(),
    "Tuesday": TextEditingController(),
    "Wednesday": TextEditingController(),
    "Thursday": TextEditingController(),
    "Friday": TextEditingController(),
    "Saturday": TextEditingController(),
    "Sunday": TextEditingController(),
  };

 void goNext() {
  final data = hoursControllers.map(
    (key, value) => MapEntry(key, value.text),
  );

  bool hasData = data.values.any((v) => v.isNotEmpty);

  if (!hasData) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Enter at least one day")),
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EnergyScreen(hoursData: data),
    ),
  );
}
  @override
  void dispose() {
    hoursControllers.forEach((k, v) => v.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(title: const Text("Step 1: Free Hours")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: hoursControllers.entries.map((entry) {
                  return FreeHoursField(
                    day: entry.key,
                    controller: entry.value,
                  );
                }).toList(),
              ),
            ),

            ElevatedButton(
              onPressed: (){
                 Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnergyScreen(
          hoursData: hoursControllers.map(
            (key, value) => MapEntry(key, value.text),
          ),
        ),
      ),
    );
              },
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}