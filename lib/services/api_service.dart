import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ এখানে আপনার Apps Script URL দিন (শেষে /exec আছে কি না দেখুন)
  static const String baseUrl = 'https://script.google.com/macros/s/AKfycbym4x7w8O8My3nxHibkCIxXlvFpTEmJnOd7LQMsAt07gFdJ0h_ixzMI2GIDLAvax5pwAg/exec';

  // ডেটা পড়ার ফাংশন (GET)
  static Future<dynamic> getAllMembers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?action=getAllMembers'));
      if (response.statusCode == 200) {
        if (response.body.contains("<!DOCTYPE html>")) {
          return {"error": "API লিংকটি ভুল বা গুগল লগইন চাচ্ছে। Deploy আবার চেক করুন।"};
        }
        return jsonDecode(response.body);
      } else {
        return {"error": "সার্ভার এরর: ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "ইন্টারনেট সমস্যা: $e"};
    }
  }

  // নতুন ডেটা পাঠানোর ফাংশন (POST)
  static Future<Map<String, dynamic>> addMember({
    required String name,
    required String phone,
    required String email,
    required String pin,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl?action=addMember'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "phone": phone,
          "email": email,
          "pin": pin,
          "role": role,
        }),
      );

      if (response.statusCode == 200) {
        // HTML পেজ আসলে সেটি হ্যান্ডেল করা
        if (response.body.contains("<!DOCTYPE html>")) {
           return {"status": "error", "message": "গুগল অনুমতি চাচ্ছে। Apps Script-এ 'New version' দিয়ে Deploy করুন।"};
        }
        return jsonDecode(response.body);
      } else {
        return {"status": "error", "message": "সার্ভার এরর: ${response.statusCode}"};
      }
    } catch (e) {
      return {"status": "error", "message": "ইন্টারনেট সমস্যা: $e"};
    }
  }
}