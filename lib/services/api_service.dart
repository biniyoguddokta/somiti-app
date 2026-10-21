import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ এখানে আপনার Apps Script URL দিন (যেটি Deploy করার পর পেয়েছেন)
  static const String baseUrl = 'https://script.google.com/macros/s/AKfycbzu3cVu5OLUujiqdaFz6siX7AEk_s7jjrxjbhj641aYhAnNraK6JenS11ZIks1eOn0_/exec';

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