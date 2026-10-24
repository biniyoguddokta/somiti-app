import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminManageScreen extends StatefulWidget {
  const AdminManageScreen({super.key});

  @override
  State<AdminManageScreen> createState() => _AdminManageScreenState();
}

class _AdminManageScreenState extends State<AdminManageScreen> {
  List<dynamic> members = [];
  bool isLoading = true;

  @override
  void initState() { super.initState(); _loadMembers(); }

  void _loadMembers() async {
    setState(() => isLoading = true);
    var res = await ApiService.getAllMembers();
    if (res is List) { 
      setState(() { members = res; isLoading = false; }); 
    } else { 
      setState(() => isLoading = false); 
    }
  }

  void _changeRole(String phone, String currentRole) async {
    String newRole = currentRole == "Admin" ? "Member" : "Admin";
    setState(() => isLoading = true);
    
    // এখানে updateRole কল করা হয়েছে
    var res = await ApiService.updateRole(phone: phone, newRole: newRole);
    
    if (res['status'] == "success" || res['status'] == "error" && res['message'].contains("302")) {
      _loadMembers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("রোল আপডেট হয়েছে!"), backgroundColor: Colors.green));
    } else {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "সমস্যা"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("সদস্য ম্যানেজ করুন"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: isLoading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          var m = members[index];
          bool isAdmin = m['Role'] == 'Admin';
          return ListTile(
            leading: CircleAvatar(backgroundColor: isAdmin ? Colors.green : Colors.blue, child: Text(m['Name'].toString().substring(0,1))),
            title: Text(m['Name'].toString()),
            subtitle: Text(m['Phone'].toString()),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: isAdmin ? Colors.red : Colors.green),
              onPressed: () => _changeRole(m['Phone'].toString(), m['Role'].toString()),
              child: Text(isAdmin ? "রিমুভ অ্যাডমিন" : "অ্যাডমিন বানান", style: const TextStyle(color: Colors.white, fontSize: 10)),
            ),
          );
        },
      ),
    );
  }
}