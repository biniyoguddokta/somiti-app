import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ এখানে আপনার Apps Script URL দিন (শেষে /exec আছে কি না দেখুন)
  static const String baseUrl = 'https://script.google.com/macros/s/AKfycbym4x7w8O8My3nxHibkCIxXlvFpTEmJnOd7LQMsAt07gFdJ0h_ixzMI2GIDLAvax5pwAg/exec';

  static Future<dynamic> getAllMembers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?action=getAllMembers'));
      
      if (response.statusCode == 200) {
        // চেক করা হচ্ছে ডেটা JSON কি না (গুগল লগইন পেজ আসলে এই এরর দেখাবে)
        if (response.body.contains("<!DOCTYPE html>")) {
          return {"error": "API লিংকটি ভুল বা গুগল লগইন চাচ্ছে। Deploy আবার চেক করুন।"};
        }
        return jsonDecode(response.body);
      } else {
        return {"error": "সার্ভার এরর: ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "ইন্টারনেট সমস্যা বা কোডে ভুল আছে: $e"};
    }
  }
}