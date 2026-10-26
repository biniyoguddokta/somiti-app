import 'package:flutter/material.dart';

class EntrepreneurSettingsScreen extends StatefulWidget {
  const EntrepreneurSettingsScreen({super.key});

  @override
  State<EntrepreneurSettingsScreen> createState() => _EntrepreneurSettingsScreenState();
}

class _EntrepreneurSettingsScreenState extends State<EntrepreneurSettingsScreen> {
  bool isAutoNotification = true;
  String currency = "৳ (BDT)";

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("উদ্যোক্তা সেটিংস"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Card(
            color: isDark ? Colors.grey[800] : Colors.white,
            child: ListTile(
              leading: const Icon(Icons.language, color: Color(0xFF00796B)),
              title: const Text("ভাষা (Language)"),
              subtitle: const Text("বাংলা (ডিফল্ট)"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ),
          Card(
            color: isDark ? Colors.grey[800] : Colors.white,
            child: ListTile(
              leading: const Icon(Icons.attach_money, color: Color(0xFF00796B)),
              title: const Text("মুদ্রা (Currency)"),
              subtitle: Text(currency),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ),
          Card(
            color: isDark ? Colors.grey[800] : Colors.white,
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications, color: Color(0xFF00796B)),
              title: const Text("অটো রিমাইন্ডার"),
              subtitle: const Text("বকেয়া বা লেনদেনের জন্য রিমাইন্ডার"),
              value: isAutoNotification,
              activeColor: const Color(0xFF00796B),
              onChanged: (val) => setState(() => isAutoNotification = val),
            ),
          ),
        ],
      ),
    );
  }
}