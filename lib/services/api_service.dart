import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'YOUR_APPS_SCRIPT_URL_HERE'; // 🔥 আপনার URL দিন

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

  static Future<dynamic> getTransactions() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl?action=getTransactions'));
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
      
      // 🔥 এখানে 302 চেক করা হয়েছে
      if (res.statusCode == 200 || res.statusCode == 302) {
        // যদি HTML পেজ আসে (অনুমতি না থাকলে)
        if (res.body.contains("<!DOCTYPE html>")) {
          return {"status": "error", "message": "গুগল পারমিশন চাচ্ছে। Apps Script চেক করুন।"};
        }
        // যদি 302 আসে, তবে ডেটা আগেই সেভ হয়ে গেছে
        if (res.statusCode == 302) {
            return {"status": "success", "message": "সদস্য যোগ হয়েছে (302)"};
        }
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
      
      // 🔥 এখানে 302 চেক করা হয়েছে
      if (res.statusCode == 200 || res.statusCode == 302) {
        if (res.body.contains("<!DOCTYPE html>")) {
          return {"status": "error", "message": "গুগল পারমিশন চাচ্ছে।"};
        }
        if (res.statusCode == 302) {
            return {"status": "success", "message": "লেনদেন সেভ হয়েছে (302)"};
        }
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
      
      // 🔥 এখানে 302 চেক করা হয়েছে
      if (res.statusCode == 200 || res.statusCode == 302) {
        if (res.body.contains("<!DOCTYPE html>")) {
          return {"status": "error", "message": "গুগল পারমিশন চাচ্ছে।"};
        }
        if (res.statusCode == 302) {
            return {"status": "success", "message": "রোল আপডেট হয়েছে (302)"};
        }
        return jsonDecode(res.body);
      }
      return {"status": "error", "message": "সার্ভার এরর: ${res.statusCode}"};
    } catch (e) { return {"status": "error", "message": "ইন্টারনেট সমস্যা: $e"}; }
  }
}