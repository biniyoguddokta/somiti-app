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
  String name = "", role = "", phone = "";

  @override
  void initState() { super.initState(); _loadData(); }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('userName') ?? "User";
      role = prefs.getString('userRole') ?? "Member";
      phone = prefs.getString('userPhone') ?? "";
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircleAvatar(radius: 50, backgroundColor: Color(0xFF00796B), child: Icon(Icons.person, size: 60, color: Colors.white)),
          const SizedBox(height: 15),
          Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text("$role • $phone", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          
          if (role == "Admin")
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: Color(0xFF00796B)),
              title: const Text("সদস্য ম্যানেজমেন্ট (রোল চেঞ্জ)"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminManageScreen())),
            ),
            
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("লগআউট করুন", style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}