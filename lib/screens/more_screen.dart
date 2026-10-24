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
  bool isBengali = true; // ভাষা পরিবর্তনের জন্য

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("আরও"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // প্রোফাইল হেডার
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  const CircleAvatar(radius: 35, backgroundColor: Color(0xFF00796B), child: Icon(Icons.person, size: 40, color: Colors.white)),
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
            
            // সেটিংস মেনু
            _buildMenuTile(Icons.person_outline, "প্রোফাইল সম্পাদনা", () {}),
            
            // উদ্যোক্তা সেটিংস (সমান সাইজ করা হলো)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                      child: const Row(
                        children: [
                          Icon(Icons.settings, color: Colors.teal),
                          SizedBox(width: 10),
                          Expanded(child: Text("অ্যাপ সেটিংস", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                      child: const Row(
                        children: [
                          Icon(Icons.settings_suggest, color: Colors.green),
                          SizedBox(width: 10),
                          Expanded(child: Text("উদ্যোক্তা সেটিংস", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ভিডিও টিউটোরিয়াল
            ListTile(
              leading: const Icon(Icons.play_circle_fill, color: Colors.red),
              title: const Text("ভিডিও টিউটোরিয়াল"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {},
            ),

            _buildMenuTile(Icons.help_outline, "সহায়তা ও যোগাযোগ", () {}),
            _buildMenuTile(Icons.info_outline, "অ্যাপ সম্পর্কে", () {}), 
            
            // ভাষা পরিবর্তন
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    const Icon(Icons.translate, color: Color(0xFF00796B)),
                    const SizedBox(width: 15),
                    const Expanded(child: Text("অ্যাপের ভাষা", style: TextStyle(fontWeight: FontWeight.bold))),
                    ToggleButtons(
                      borderRadius: BorderRadius.circular(20),
                      isSelected: [isBengali, !isBengali],
                      onPressed: (index) {
                        setState(() { isBengali = index == 0; });
                        // এখানে ভাষা পরিবর্তনের লজিক বসবে
                      },
                      children: const [
                        Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("বাংলা")),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("English")),
                      ],
                    ),
                  ],
                ),
              ),
            ),

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