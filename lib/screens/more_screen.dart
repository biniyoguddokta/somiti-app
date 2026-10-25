import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'app_settings_screen.dart';
import 'video_tutorial_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String name = "", role = "", phone = "";
  bool isLoadingStats = true;

  // স্ট্যাটস ভ্যারিয়েবল
  double totalDeposit = 0.0;
  double totalProfit = 0.0;
  int activeProjects = 0;

  @override
  void initState() { 
    super.initState(); 
    _loadData(); 
  }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('userName') ?? "User";
      role = prefs.getString('userRole') ?? "Member";
      phone = prefs.getString('userPhone') ?? "";
    });

    _fetchStats();
  }

  void _fetchStats() async {
    // ১. লেনদেন থেকে জমা ও লাভ বের করা
    var txRes = await ApiService.getTransactions();
    if (txRes is List) {
      double tempDeposit = 0.0;
      for (var tx in txRes) {
        double amount = double.tryParse(tx['Amount'].toString()) ?? 0.0;
        if (tx['Type'] == 'জমা' && tx['Status'] == 'Paid') tempDeposit += amount;
      }
      setState(() => totalDeposit = tempDeposit);
    }

    // ২. বিনিয়োগ থেকে লাভ ও সক্রিয় প্রকল্প বের করা
    var invRes = await ApiService.getInvestments();
    if (invRes is List) {
      double tempProfit = 0.0;
      int tempActive = 0;
      for (var inv in invRes) {
        double profit = double.tryParse(inv['ProfitAmount'].toString()) ?? 0.0;
        tempProfit += profit;
        if (inv['Status'] == 'সক্রিয়') tempActive++;
      }
      setState(() {
        totalProfit = tempProfit;
        activeProjects = tempActive;
        isLoadingStats = false;
      });
    } else {
      setState(() => isLoadingStats = false);
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
  }

  // পিন পরিবর্তনের ডায়ালগ
  void _showPinChangeDialog() {
    TextEditingController oldPinController = TextEditingController();
    TextEditingController newPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("পিন পরিবর্তন করুন"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldPinController, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "পুরোনো পিন")),
            const SizedBox(height: 10),
            TextField(controller: newPinController, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "নতুন পিন")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("বাতিল")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // এখানে API কল করে পিন আপডেট হবে (Apps Script আপডেটের পর)
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("পিন আপডেটের ফিচারটি পরবর্তী আপডেটে আসছে")));
            },
            child: const Text("সেভ"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("প্রোফাইল"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // প্রোফাইল হেডার ও স্ট্যাটস
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.white),
              child: Column(
                children: [
                  Row(
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
                  const SizedBox(height: 20),
                  // স্ট্যাটস কার্ড
                  isLoadingStats 
                    ? const CircularProgressIndicator()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem("মোট জমা", "৳ ${totalDeposit.toStringAsFixed(0)}", Colors.green),
                          _buildStatItem("মোট লাভ", "৳ ${totalProfit.toStringAsFixed(0)}", Colors.blue),
                          _buildStatItem("সক্রিয় প্রকল্প", "$activeProjects টি", Colors.orange),
                        ],
                      )
                ],
              ),
            ),
            
            const SizedBox(height: 10),

            // মেনু অপশন
            _buildMenuTile(Icons.notifications_none, "নোটিফিকেশন সেটিংস", () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const AppSettingsScreen()));
            }),
            _buildMenuTile(Icons.security, "সুরক্ষা ও গোপনীয়তা (পিন)", _showPinChangeDialog),
            _buildMenuTile(Icons.play_circle_fill, "ভিডিও টিউটোরিয়াল", () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const VideoTutorialScreen()));
            }),
            _buildMenuTile(Icons.info_outline, "অ্যাপ সম্পর্কে", () {
              showAboutDialog(
                context: context,
                applicationName: "বিনিয়োগ উদ্যোক্তা",
                applicationVersion: "1.0.0",
                applicationIcon: const Icon(Icons.monetization_on, color: Color(0xFF00796B), size: 50),
                children: [const Text("সমিতির সব হিসাব এক অ্যাপে। ডেভেলপড বাই বিনিয়োগ উদ্যোক্তা টিম।")]
              );
            }),
            
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

  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}