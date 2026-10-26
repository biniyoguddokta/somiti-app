import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("নির্দেশিকা / ম্যানুয়াল"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          _buildGuideCard(context, "কিভাবে সদস্য যোগ করবেন?", "মডিউল ও ফিচার থেকে 'সদস্য যোগ' এ ক্লিক করুন। এরপর নাম, মোবাইল, পদবি এবং ৪ ডিজিটের পিন দিয়ে সেভ করুন।", isDark),
          _buildGuideCard(context, "কিভাবে জমা বা খরচ লিখবেন?", "হোম পেজের নিচে 'জমা' বা 'খরচ' বাটনে ক্লিক করুন। পরিমাণ ও নোট লিখে সেভ করুন।", isDark),
          _buildGuideCard(context, "বিনিয়োগ প্রজেক্ট তৈরি", "হোম পেজ থেকে 'বিনিয়োগ' এ যান। নতুন প্রজেক্ট তৈরি করে লাভের পরিমাণ উল্লেখ করুন।", isDark),
        ],
      ),
    );
  }

  Widget _buildGuideCard(BuildContext context, String title, String desc, bool isDark) {
    return Card(
      color: isDark ? Colors.grey[800] : Colors.white,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(desc, style: const TextStyle(height: 1.5)),
          )
        ],
      ),
    );
  }
}