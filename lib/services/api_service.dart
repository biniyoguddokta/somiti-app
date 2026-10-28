import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://script.google.com/macros/s/AKfycby8WDNL-Mvy34P04vw_zbkexLjE8OjqDIXVlP7HYS6Bq6R_v8SEqhLPx3sL0Q89YdvetQ/exec'; 

  static Future<dynamic> _getData(String action) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl?action=$action'));
      if (res.body.contains("<!DOCTYPE html>") || res.body.contains("<html>")) return {"error": "Permission Issue"};
      if (res.statusCode == 200) return jsonDecode(res.body);
      return {"error": "Server Error: ${res.statusCode}"};
    } catch (e) { return {"error": "Internet Issue: $e"}; }
  }

  static Future<Map<String, dynamic>> _postData(String action, Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl?action=$action'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      
      // 🔥 302 আসলে সেটি সফল ধরা হবে (কারণ ডেটা ইতিমধ্যে সেভ হয়ে গেছে)
      if (res.statusCode == 302) {
        return {"status": "success", "message": "Success (302)"};
      }

      if (res.body.contains("<!DOCTYPE html>") || res.body.contains("<html>")) {
        return {"status": "error", "message": "Permission Issue"};
      }
      
      if (res.statusCode == 200) {
        try {
          var decoded = jsonDecode(res.body);
          return decoded;
        } catch (e) {
           return {"status": "success", "message": "Success"};
        }
      }
      return {"status": "error", "message": "Server Error: ${res.statusCode}"};
    } catch (e) { return {"status": "error", "message": "Internet Issue: $e"}; }
  }

  static Future<dynamic> getAllMembers() => _getData("getAllMembers");
  static Future<Map<String, dynamic>> addMember({required String name, required String phone, required String email, required String pin, required String role, required String designation}) 
    => _postData("addMember", {"name": name, "phone": phone, "email": email, "pin": pin, "role": role, "designation": designation});
  static Future<Map<String, dynamic>> updateRole({required String phone, required String newRole}) 
    => _postData("updateRole", {"phone": phone, "newRole": newRole});
  static Future<Map<String, dynamic>> updateDesignation({required String phone, required String designation}) 
    => _postData("updateDesignation", {"phone": phone, "designation": designation});
  static Future<Map<String, dynamic>> updatePin({required String phone, required String newPin}) 
    => _postData("updatePin", {"phone": phone, "newPin": newPin});
  static Future<Map<String, dynamic>> updateProfilePic({required String phone, required String base64})
    => _postData("updateProfilePic", {"phone": phone, "base64": base64});
    
  static Future<dynamic> getTransactions() => _getData("getTransactions");
  static Future<Map<String, dynamic>> addTransaction({required String type, required String amount, required String note, required String memberName, required String status, required String date, required String paymentMethod}) 
    => _postData("addTransaction", {"type": type, "amount": amount, "note": note, "memberName": memberName, "status": status, "date": date, "paymentMethod": paymentMethod});
  static Future<Map<String, dynamic>> updateTransactionStatus({required String rowIndex, required String status})
    => _postData("updateTransactionStatus", {"rowIndex": rowIndex, "status": status});
  static Future<Map<String, dynamic>> generateAutoDue() => _postData("generateAutoDue", {});
  static Future<dynamic> getInvestments() => _getData("getInvestments");
  static Future<Map<String, dynamic>> addInvestment({required String sector, required String projectName, required String investAmount, required String startDate, required String endDate, required String profitAmount}) 
    => _postData("addInvestment", {"sector": sector, "projectName": projectName, "investAmount": investAmount, "startDate": startDate, "endDate": endDate, "profitAmount": profitAmount});
  static Future<dynamic> getConstitution() => _getData("getConstitution");
  static Future<dynamic> getLateFees() => _getData("getLateFees");
}