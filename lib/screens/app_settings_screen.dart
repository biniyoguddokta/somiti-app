import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // themeNotifier এর জন্য

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool isNotificationOn = true;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    isDarkMode = themeNotifier.value == ThemeMode.dark;
  }

  void _toggleDarkMode(bool value) async {
    setState(() => isDarkMode = value);
    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("অ্যাপ সেটিংস"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: SwitchListTile(
              title: const Text("ডার্ক মোড", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("অ্যাপের কালার পরিবর্তন করুন"),
              value: isDarkMode,
              activeColor: const Color(0xFF00796B),
              onChanged: _toggleDarkMode,
            ),
          ),
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
        ],
      ),
    );
  }
}