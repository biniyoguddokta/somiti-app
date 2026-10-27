import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 🔥 আপনার Apps Script URL (শেষে /exec আছে, ?action= নেই)
  static const String baseUrl = 'https://script.google.com/macros/s/AKfycby8WDNL-Mvy34P04vw_zbkexLjE8OjqDIXVlP7HYS6Bq6R_v8SEqhLPx3sL0Q89YdvetQ/exec'; 

  // ==========================================
  // ১. ডেটা পড়ার ফাংশন (GET)
  // ==========================================
  static Future<dynamic> _getData(String action) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl?action=$action'));
      
      if (res.body.contains("<!DOCTYPE html>") || res.body.contains("<html>")) {
        return {"error": "Permission Issue: API returned HTML. Deploy চেক করুন।"};
      }

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {"error": "Server Error: ${res.statusCode}"};
    } catch (e) { 
      return {"error": "Internet Issue: $e"}; 
    }
  }

  // ==========================================
  // ২. ডেটা পাঠানোর ফাংশন (POST) - ঠিক করা হলো
  // ==========================================
  static Future<Map<String, dynamic>> _postData(String action, Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl?action=$action'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      // যদি গুগল লগইন পেজ বা HTML এরর পাঠায়
      if (res.body.contains("<!DOCTYPE html>") || res.body.contains("<html>")) {
        return {"status": "error", "message": "Permission Issue: Google HTML Page returned. Apps Script-এ 'Anyone' দেওয়া আছে কি না চেক করুন।"};
      }

      // যদি স্ট্যাটাস ২০০ হয়
      if (res.statusCode == 200) {
        try {
          var decoded = jsonDecode(res.body);
          if (decoded['status'] == 'success') {
            return decoded;
          } else {
            return {"status": "error", "message": decoded['message'] ?? "Server returned error"};
          }
        } catch (e) {
          return {"status": "error", "message": "Invalid JSON response from server"};
        }
      }
      
      // ৩০২ রিডাইরেক্ট আসলে সেটি সফল নয়, বরং লগইন পেজে পাঠানোর চেষ্টা
      if (res.statusCode == 302) {
         return {"status": "error", "message": "Redirect Error (302). Apps Script Deploy সেটিংস চেক করুন।"};
      }

      return {"status": "error", "message": "Server Error Code: ${res.statusCode}"};
    } catch (e) { 
      return {"status": "error", "message": "Internet Issue: $e"}; 
    }
  }

  // ==========================================
  // ৩. নির্দিষ্ট API মেথডসমূহ
  // ==========================================

  // Members & Committee
  static Future<dynamic> getAllMembers() => _getData("getAllMembers");
  
  static Future<Map<String, dynamic>> addMember({required String name, required String phone, required String email, required String pin, required String role, required String designation}) 
    => _postData("addMember", {"name": name, "phone": phone, "email": email, "pin": pin, "role": role, "designation": designation});
  
  static Future<Map<String, dynamic>> updateRole({required String phone, required String newRole}) 
    => _postData("updateRole", {"phone": phone, "newRole": newRole});
    
  static Future<Map<String, dynamic>> updateDesignation({required String phone, required String designation}) 
    => _postData("updateDesignation", {"phone": phone, "designation": designation});
  
  static Future<Map<String, dynamic>> updatePin({required String phone, required String newPin}) 
    => _postData("updatePin", {"phone": phone, "newPin": newPin});

  // Transactions
  static Future<dynamic> getTransactions() => _getData("getTransactions");
  
  static Future<Map<String, dynamic>> addTransaction({required String type, required String amount, required String note, required String memberName, required String status, required String date}) 
    => _postData("addTransaction", {"type": type, "amount": amount, "note": note, "memberName": memberName, "status": status, "date": date});
    
  static Future<Map<String, dynamic>> updateTransactionStatus({required String rowIndex, required String status})
    => _postData("updateTransactionStatus", {"rowIndex": rowIndex, "status": status});

  // Investments
  static Future<dynamic> getInvestments() => _getData("getInvestments");
  
  static Future<Map<String, dynamic>> addInvestment({required String sector, required String projectName, required String investAmount, required String startDate, required String endDate, required String profitAmount}) 
    => _postData("addInvestment", {"sector": sector, "projectName": projectName, "investAmount": investAmount, "startDate": startDate, "endDate": endDate, "profitAmount": profitAmount});

  // Constitution & Meetings
  static Future<dynamic> getConstitution() => _getData("getConstitution");
  static Future<dynamic> getMeetings() => _getData("getMeetings");
}