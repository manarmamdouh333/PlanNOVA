import 'dart:convert';
import 'package:http/http.dart' as http;

class PlanApiService {
  static Future<List<dynamic>?> generatePlan({
    required String planId,
    required String energy,
    required List<Map<String, dynamic>> tasks,
    required Map<String, String> freeHours,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost:5000/generate"), // 👈 مهم
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "plan_id": planId,
          "energy": energy,
          "tasks": tasks,
          "freeHours": freeHours,
        }),
      );

      print("🔥 STATUS CODE: ${response.statusCode}");
      print("🔥 BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

final decoded = jsonDecode(response.body);

return decoded["data"];        // 👈 دي اللي هتروح للـ PlanScreen
      } else {
        throw Exception("Server error: ${response.body}");
      }
    } catch (e) {
      print("🔥 API ERROR: $e");
      return null;
    }
  }
}