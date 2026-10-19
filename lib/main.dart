import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Somiti App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        primaryColor: const Color(0xFF4CAF50),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 👇 আপনার Apps Script এর লিংকটি এখানে বসানো হয়েছে
  final String apiUrl = "https://script.google.com/macros/s/AKfycbzu3cVu5OLUujiqdaFz6siX7AEk_s7jjrxjbhj641aYhAnNraK6JenS11ZIks1eOn0_/exec"; 
  
  List<dynamic> members = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl?action=getData"));
      if (response.statusCode == 200) {
        setState(() {
          members = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('হোম', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildTopCard(
                        title: "মোট তহবিল",
                        value: "৳ ০",
                        icon: Icons.account_balance_wallet,
                        color: Colors.purple.shade50,
                        iconColor: Colors.purple,
                      ),
                      const SizedBox(width: 12),
                      _buildTopCard(
                        title: "সদস্য",
                        value: "${members.length} জন",
                        icon: Icons.people,
                        color: Colors.blue.shade50,
                        iconColor: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "সমিতির হিসাব",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "সদস্য: ${members.length}",
                                style: const TextStyle(color: Colors.teal),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text("আজকের আদায়",
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        const Text("৳ ০",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        const Divider(height: 32),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.5,
                          children: [
                            _buildGridItem("ক্যাশ হাতে", "৳ ০",
                                Icons.money, Colors.green.shade50, Colors.green),
                            _buildGridItem("ব্যাংক", "৳ ০",
                                Icons.account_balance, Colors.blue.shade50, Colors.blue),
                            _buildGridItem("মোট দায়", "৳ ০",
                                Icons.money_off, Colors.orange.shade50, Colors.orange),
                            _buildGridItem("লোন আউটস্ট্যান্ডিং", "৳ ০",
                                Icons.receipt_long, Colors.purple.shade50, Colors.purple),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text("মডিউল ও ফিচার",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _buildFeatureButton("সদস্য যোগ", Icons.person_add, Colors.green, () {
                        _showAddMemberDialog();
                      }),
                      _buildFeatureButton("সদস্য", Icons.people, Colors.blue, () {}),
                      _buildFeatureButton("সাধারণ সদস্য", Icons.group, Colors.green.shade700, () {}),
                      _buildFeatureButton("DPS", Icons.savings, Colors.teal, () {}),
                      _buildFeatureButton("FDR", Icons.account_balance, Colors.purple, () {}),
                      _buildFeatureButton("লোন", Icons.receipt, Colors.orange, () {}),
                    ],
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "হোম"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "সদস্য"),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: "কালেকশন"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "রিপোর্ট"),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "আরও"),
        ],
      ),
    );
  }

  Widget _buildTopCard({required String title, required String value, required IconData icon, required Color color, required Color iconColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(String title, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, color: Colors.black54)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog() {
    TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("নতুন সদস্য যোগ করুন"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "সদস্যের নাম লিখুন"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("বাতিল"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context);
                await _addMemberToSheet(nameController.text);
              }
            },
            child: const Text("সেভ করুন"),
          ),
        ],
      ),
    );
  }

  Future<void> _addMemberToSheet(String name) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"action": "addMember", "name": name}),
      );
      
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("সদস্য সফলভাবে যোগ হয়েছে!")),
          );
        }
        fetchData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ইন্টারনেট বা সার্ভার সমস্যা!")),
        );
      }
    }
  }
}