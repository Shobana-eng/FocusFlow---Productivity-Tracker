// PART 1/2
// lib/services/ai_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // Replace with your Flask server URL
  // Android Emulator:
  // static const String baseUrl = "http://10.0.2.2:5000";

  // Physical Device:
  // static const String baseUrl = "http://YOUR_PC_IP:5000";

  static const String baseUrl = "http://10.0.2.2:5000";

  Future<Map<String, dynamic>> predictProductivity({
    required double studyHours,
    required double screenTime,
    required double sleepHours,
    required double focusHours,
    required double stressLevel,
    required double physicalActivity,
    required double socialMedia,
    required double breaks,
    required int unlockCount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/predict"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "study_hours": studyHours,
          "screen_time": screenTime,
          "sleep_hours": sleepHours,
          "focus_hours": focusHours,
          "stress_level": stressLevel,
          "physical_activity": physicalActivity,
          "social_media": socialMedia,
          "breaks": breaks,
          "unlock_count": unlockCount,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        "success": false,
        "message": "Server Error (${response.statusCode})",
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
}
// End of ai_service.dart