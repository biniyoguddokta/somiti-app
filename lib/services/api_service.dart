import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://script.google.com/macros/s/AKfycby8WDNL-Mvy34P04vw_zbkexLjE8OjqDIXVlP7HYS6Bq6R_v8SEqhLPx3sL0Q89YdvetQ/exec'; // 🔥 আপনার URL দিন

  static Future<dynamic> getAllMembers() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl?action=getAllMembers'));
      if (res.statusCode == 200) {
        if (res.body.contains("<!DOCTYPE html>")) return {"error": "API লিংক ভুল বা পারমিশন নেই"};
        return jsonDecode(res.body);
      }
      return {"error": "সার্ভার এরর: ${res.statusCode}"};
    } catch (e) { return {"error": "ইন্টারনেট সমস্যা: $e"}; }
  }

  static Future<Map<String, dynamic>> addMember({required String name, required String phone, required String email, required String pin, required String role}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl?action=addMember'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "phone": phone, "email": email, "pin": pin, "role": role}),
      );
      if (res.statusCode == 200) {
        if (res.body.contains("<!DOCTYPE html>")) return {"status": "error", "message": "গুগল পারমিশন চাচ্ছে। Apps Script চেক করুন।"};
        return jsonDecode(res.body);
      }
      return {"status": "error", "message": "সার্ভার এরর: ${res.statusCode}"};
    } catch (e) { return {"status": "error", "message": "ইন্টারনেট সমস্যা: $e"}; }
  }

  static Future<Map<String, dynamic>> addTransaction({required String type, required String amount, required String note, required String memberName}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl?action=addTransaction'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"type": type, "amount": amount, "note": note, "memberName": memberName}),
      );
      if (res.statusCode == 200) {
        if (res.body.contains("<!DOCTYPE html>")) return {"status": "error", "message": "গুগল পারমিশন চাচ্ছে।"};
        return jsonDecode(res.body);
      }
      return {"status": "error", "message": "সার্ভার এরর: ${res.statusCode}"};
    } catch (e) { return {"status": "error", "message": "ইন্টারনেট সমস্যা: $e"}; }
  }

  static Future<Map<String, dynamic>> updateRole({required String phone, required String newRole}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl?action=updateRole'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "newRole": newRole}),
      );
      if (res.statusCode == 200) {
        if (res.body.contains("<!DOCTYPE html>")) return {"status": "error", "message": "গুগল পারমিশন চাচ্ছে।"};
        return jsonDecode(res.body);
      }
      return {"status": "error", "message": "সার্ভার এরর: ${res.statusCode}"};
    } catch (e) { return {"status": "error", "message": "ইন্টারনেট সমস্যা: $e"}; }
  }
}