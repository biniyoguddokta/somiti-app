import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../main.dart'; // themeNotifier এর জন্য
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
  double totalInvestment = 0.0;
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
    // ১. জমা বের করা
    var txRes = await ApiService.getTransactions();
    if (txRes is List) {
      double tempDeposit = 0.0;
      for (var tx in txRes) {
        double amount = double.tryParse(tx['Amount'].toString()) ?? 0.0;
        if (tx['Type'] == 'জমা' && tx['Status'] == 'Paid') tempDeposit += amount;
      }
      setState(() => totalDeposit = tempDeposit);
    }

    // ২. বিনিয়োগ ও লাভ বের করা
    var invRes = await ApiService.getInvestments();
    if (invRes is List) {
      double tempProfit = 0.0;
      double tempInv = 0.0;
      int tempActive = 0;
      for (var inv in invRes) {
        double profit = double.tryParse(inv['ProfitAmount'].toString()) ?? 0.0;
        double amount = double.tryParse(inv['InvestAmount'].toString()) ?? 0.0;
        
        tempProfit += profit;
        if (inv['Status'] == 'সক্রিয়') {
          tempActive++;
          tempInv += amount; // সক্রিয় বিনিয়োগের টাকা যোগ
        }
      }
      setState(() {
        totalProfit = tempProfit;
        totalInvestment = tempInv;
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
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("পিন আপডেট ফিচারটি পরবর্তী আপডেটে আসছে")));
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
      appBar: AppBar(
        title: const Text("আমার প্রোফাইল"), 
        backgroundColor: const Color(0xFF00796B), 
        foregroundColor: Colors.white
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ১. সবুজ হেডার (৩ নং স্ক্রিনশট)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              decoration: const BoxDecoration(
                color: Color(0xFF00796B),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 35, backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Color(0xFF00796B))),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 5),
                      Text(role == 'Admin' ? "প্রতিষ্ঠাতা / অ্যাডমিন" : "সাধারণ সদস্য", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  )
                ],
              ),
            ),

            // ২. স্ট্যাটস কার্ড (মোট বিনিয়োগ, লাভ ইত্যাদি)
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: isLoadingStats 
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(child: _buildStatCard("মোট লাভ", "৳ ${totalProfit.toStringAsFixed(0)}", Icons.trending_up, Colors.green, isDark)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildStatCard("মোট জমা", "৳ ${totalDeposit.toStringAsFixed(0)}", Icons.account_balance_wallet, Colors.blue, isDark)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildStatCard("সক্রিয় প্রকল্প", "$activeProjects টি", Icons.layers, Colors.orange, isDark)),
                      ],
                    ),
              ),
            ),

            // ৩. মেনু অপশন
            _buildMenuTile(Icons.notifications_none, "নোটিফিকেশন সেটিংস", () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const AppSettingsScreen()));
            }),
            _buildMenuTile(Icons.security, "সুরক্ষা ও গোপনীয়তা (পিন)", _showPinChangeDialog),
            
            // 🔥 ডার্ক মোড অপশন (ভিডিওর জায়গায় বসানো হলো)
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode, color: Colors.blueGrey),
              title: const Text("ডার্ক মোড", style: TextStyle(fontWeight: FontWeight.w500)),
              value: themeNotifier.value == ThemeMode.dark,
              activeColor: const Color(0xFF00796B),
              onChanged: (val) async {
                themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isDarkMode', val);
              },
            ),

            _buildMenuTile(Icons.play_circle_fill, "ভিডিও টিউটোরিয়াল", () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const VideoTutorialScreen()));
            }),
            _buildMenuTile(Icons.info_outline, "অ্যাপ সম্পর্কে", () {
              showAboutDialog(
                context: context,
                applicationName: "বিনিয়োগ উদ্যোক্তা",
                applicationVersion: "1.0.0",
                children: [const Text("সমিতির সব হিসাব এক অ্যাপে।")]
              );
            }),
            
            const SizedBox(height: 20),
            
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("লগআউট", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: _logout,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 4),
          FittedBox(child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14))),
        ],
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