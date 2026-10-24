import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool isNotificationOn = true;
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("অ্যাপ সেটিংস"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: SwitchListTile(
              title: const Text("নোটিফিকেশন", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("নতুন আপডেট পুশ নোটিফিকেশন"),
              value: isNotificationOn,
              activeColor: const Color(0xFF00796B),
              onChanged: (val) => setState(() => isNotificationOn = val),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: SwitchListTile(
              title: const Text("ডার্ক মোড", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("অ্যাপের কালার পরিবর্তন করুন"),
              value: isDarkMode,
              activeColor: const Color(0xFF00796B),
              onChanged: (val) => setState(() => isDarkMode = val),
            ),
          ),
        ],
      ),
    );
  }
}