import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ এখানে আপনার Apps Script URL দিন (যেটি Deploy করার পর পেয়েছেন)
  static const String baseUrl = 'YOUR_APPS_SCRIPT_URL_HERE';

  // সব সদস্যের ডেটা আনার ফাংশন
  static Future<List<dynamic>> getAllMembers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?action=getAllMembers'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
}