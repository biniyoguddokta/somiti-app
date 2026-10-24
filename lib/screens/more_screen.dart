import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'admin_manage_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String name = "", role = "", phone = "", email = "";

  @override
  void initState() { super.initState(); _loadData(); }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('userName') ?? "User";
      role = prefs.getString('userRole') ?? "Member";
      phone = prefs.getString('userPhone') ?? "";
      email = prefs.getString('userEmail') ?? "user@gmail.com"; 
    });
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("প্রোফাইল"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // প্রোফাইল হেডার
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFF00796B),
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text("${phone.substring(0, 3)}***@gmail.com", style: const TextStyle(color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),
            
            // মেনু লিস্ট
            _buildMenuTile(Icons.person_outline, "প্রোফাইল সম্পাদনা", () {}),
            _buildMenuTile(Icons.notifications_none, "নোটিফিকেশন সেটিংস", () {}),
            _buildMenuTile(Icons.security, "সুরক্ষা ও গোপনীয়তা", () {}),
            
            if (role == "Admin") ...[
              const Divider(),
              _buildMenuTile(Icons.admin_panel_settings, "সদস্য ম্যানেজমেন্ট (রোল)", () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminManageScreen()));
              }),
              const Divider(),
            ],

            _buildMenuTile(Icons.help_outline, "সহায়তা ও যোগাযোগ", () {}), 
            _buildMenuTile(Icons.info_outline, "অ্যাপ সম্পর্কে", () {}), 
            
            const SizedBox(height: 20),
            
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("লগআউট", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: _logout,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}