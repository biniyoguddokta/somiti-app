import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool isNotificationOn = true;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("নোটিফিকেশন সেটিংস"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Card(
            color: isDark ? Colors.grey[800] : Colors.white,
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