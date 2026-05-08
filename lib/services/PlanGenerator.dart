class PlanGenerator {
  static Map<String, List<Map<String, dynamic>>> generate({
    required Map<String, String> days,
    required List<Map<String, dynamic>> tasks,
    required String energy,
  }) {
    // 🟢 convert hours → minutes
    Map<String, int> freeMinutes = {};
    days.forEach((day, hrs) {
      freeMinutes[day] = (int.tryParse(hrs) ?? 0) * 60;
    });

    // 🟢 ترتيب التاسكات
    List<Map<String, dynamic>> sortedTasks = List.from(tasks);

    if (energy == "Morning") {
      sortedTasks.sort((a, b) =>
          int.parse(b["priority"]).compareTo(int.parse(a["priority"])));
    } else {
      sortedTasks.sort((a, b) =>
          int.parse(a["priority"]).compareTo(int.parse(b["priority"])));
    }

    // 🟢 init plan
    Map<String, List<Map<String, dynamic>>> plan = {};
    for (var day in freeMinutes.keys) {
      plan[day] = [];
    }

    List<String> daysList = freeMinutes.keys.toList();
    int dayIndex = 0;

    // 🔥 توزيع Round Robin
    for (var task in sortedTasks) {
      int duration = int.tryParse(task["duration"]) ?? 0;

      int attempts = 0;
      bool assigned = false;

      while (attempts < daysList.length) {
        String currentDay = daysList[dayIndex];

        if (duration <= freeMinutes[currentDay]! && duration > 0) {
          plan[currentDay]!.add(task);
          freeMinutes[currentDay] =
              freeMinutes[currentDay]! - duration;

          assigned = true;
          break;
        }

        // move to next day
        dayIndex = (dayIndex + 1) % daysList.length;
        attempts++;
      }

      // move next anyway (balance)
      dayIndex = (dayIndex + 1) % daysList.length;

      // لو متحطتش خالص
      if (!assigned) {
        // ممكن نضيف backlog بعدين
        print("⚠️ Task not assigned: ${task["title"]}");
      }
    }

    return plan;
  }
}