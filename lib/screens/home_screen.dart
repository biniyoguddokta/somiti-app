import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; 

import '../services/api_service.dart';
import 'members_screen.dart';
import 'add_member_screen.dart';
import 'more_screen.dart';
import 'add_transaction_screen.dart';
import 'collection_screen.dart';
import 'constitution_screen.dart';
import 'late_fee_screen.dart';
import 'meeting_screen.dart';
import 'due_list_screen.dart'; 
import 'report_screen.dart'; 
import 'transaction_list_screen.dart'; // লিস্ট পেজ
import 'investment_screen.dart'; // নতুন ইমপোর্ট
import 'committee_screen.dart'; // নতুন ইমপোর্ট

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<HomeContentState> _homeKey = GlobalKey<HomeContentState>();

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeContent(key: _homeKey),
      const MembersScreen(),
      const CollectionScreen(),
      const ReportScreen(), 
      const MoreScreen(),
    ];

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF00796B)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("বিনিয়োগ উদ্যোক্তা", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text("সব হিসাব এক অ্যাপে", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Color(0xFF00796B)),
              title: const Text("সভা (মিটিং)"),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (c) => const MeetingScreen())); },
            ),
            ListTile(
              leading: const Icon(Icons.money_off, color: Colors.red),
              title: const Text("বিলম্ব ফী"),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (c) => const LateFeeScreen())); },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.blue),
              title: const Text("গঠনতন্ত্র"),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (c) => const ConstitutionScreen())); },
            ),
          ],
        ),
      ),
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00796B),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 0) _homeKey.currentState?.fetchDashboardData();
        },
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
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});
  @override
  State<HomeContent> createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentBanner = 0;
  String userName = "Admin";
  String userRole = "Member";
  bool _isLoadingStats = true;
  bool _showTotalAssets = false; 

  double cashInHand = 0.0;
  double todayDeposit = 0.0;
  double todayExpense = 0.0;
  int totalTransactions = 0;
  List<dynamic> recentTransactions = [];

  final List<String> banners = [
    'https://via.placeholder.com/800x300/00796B/FFFFFF?text=Banner+1',
    'https://via.placeholder.com/800x300/F44336/FFFFFF?text=Banner+2',
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
    fetchDashboardData(); 
  }

  void _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "User";
      userRole = prefs.getString('userRole') ?? "Member";
    });
  }

  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "শুভ সকাল";
    if (hour >= 12 && hour < 16) return "শুভ দুপুর";
    if (hour >= 16 && hour < 18) return "শুভ বিকাল";
    if (hour >= 18 && hour < 20) return "শুভ সন্ধ্যা";
    return "শুভ রাত্রি";
  }

  Future<void> fetchDashboardData() async {
    setState(() => _isLoadingStats = true);
    var response = await ApiService.getTransactions();
    
    if (response is List) {
      double tempCash = 0.0;
      double tempTodayDeposit = 0.0;
      double tempTodayExpense = 0.0;
      int tempTotalTx = response.length;
      List<dynamic> tempRecent = [];

      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      for (var tx in response) {
        String type = tx['Type'].toString();
        double amount = double.tryParse(tx['Amount'].toString()) ?? 0.0;
        String dateStr = tx['Date'].toString();

        if (type == 'জমা' || type == 'আয়' || type == 'বিনিয়োগ') tempCash += amount;
        else if (type == 'খরচ') tempCash -= amount;

        if (dateStr.contains(todayDate)) {
          if (type == 'জমা') tempTodayDeposit += amount;
          if (type == 'খরচ') tempTodayExpense += amount;
        }
      }

      if (response.length > 5) {
        tempRecent = response.sublist(response.length - 5).reversed.toList();
      } else {
        tempRecent = response.reversed.toList();
      }

      setState(() {
        cashInHand = tempCash;
        todayDeposit = tempTodayDeposit;
        todayExpense = tempTodayExpense;
        totalTransactions = tempTotalTx;
        recentTransactions = tempRecent;
        _isLoadingStats = false;
      });
    } else {
      setState(() => _isLoadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Color(0xFF00796B), size: 30),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  const Icon(Icons.person, color: Color(0xFF00796B), size: 30),
                ],
              ),
            ),
            
            SizedBox(
              height: 160,
              child: CarouselSlider(
                carouselController: _carouselController,
                options: CarouselOptions(
                  autoPlay: true, autoPlayInterval: const Duration(seconds: 3), enlargeCenterPage: true, viewportFraction: 0.9,
                  onPageChanged: (index, reason) => setState(() => _currentBanner = index),
                ),
                items: banners.map((bannerUrl) => Builder(
                  builder: (context) => Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(bannerUrl, fit: BoxFit.fill, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image)))),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 10),
            
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => const DueListScreen()));
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: const [
                    Icon(Icons.lock_clock, color: Colors.white, size: 35), SizedBox(width: 15),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("সদস্য যাদের জমা বকেয়া আছে", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 5), Text("বকেয়া গুলো দেখতে ট্যাপ করুন", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    )),
                    Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(children: [
                Text("${getGreeting()}, ", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                Text("$userName ", style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold)),
              ]),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("বিনিয়োগ উদ্যোক্তা", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GestureDetector(
                onTap: () => setState(() => _showTotalAssets = !_showTotalAssets),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E24AA), 
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: const Color(0xFF8E24AA).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Center(
                    child: Text(
                      _showTotalAssets ? "৳ ${cashInHand.toStringAsFixed(0)}" : "Tap for Balance",
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: _isLoadingStats 
                ? const Center(child: CircularProgressIndicator())
                : Row(children: [
                    Expanded(child: _buildInfoCard("হাতে নগদ", "৳ ${cashInHand.toStringAsFixed(0)}", Icons.account_balance_wallet, Colors.blue)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInfoCard("আজকের জমা", "৳ ${todayDeposit.toStringAsFixed(0)}", Icons.arrow_downward, Colors.green)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInfoCard("আজকের খরচ", "৳ ${todayExpense.toStringAsFixed(0)}", Icons.arrow_upward, Colors.orange)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInfoCard("সব লেনদেন", "$totalTransactions টি", Icons.receipt_long, Colors.red)),
                  ]),
            ),
            const SizedBox(height: 20),
            
            // ৪টি অ্যাকশন বাটন
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _buildActionButton(context, "জমা", Icons.money, const Color(0xFF43A047), "জমা"),
                _buildActionButton(context, "খরচ", Icons.shopping_bag, const Color(0xFFE53935), "খরচ"),
                _buildActionButton(context, "আয়", Icons.savings, const Color(0xFF00897B), "আয়"),
                _buildActionButton(context, "বিনিয়োগ", Icons.menu_book, const Color(0xFF8E24AA), "বিনিয়োগ"),
              ]),
            ),
            const SizedBox(height: 30),
            
            const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("মডিউল ও ফিচার", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey))),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GridView.count(
                crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 15, crossAxisSpacing: 15, childAspectRatio: 1,
                children: [
                  InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const MembersScreen())), borderRadius: BorderRadius.circular(15), child: _buildModuleIcon(Icons.people, "সদস্য", Colors.blue)),
                  if (userRole == 'Admin')
                    InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AddMemberScreen())), borderRadius: BorderRadius.circular(15), child: _buildModuleIcon(Icons.person_add, "সদস্য যোগ", Colors.green)),
                  
                  // কমিটি পেজ লিংক করা হলো
                  InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => CommitteeScreen(userRole: userRole))), borderRadius: BorderRadius.circular(15), child: _buildModuleIcon(Icons.group, "কমিটি", Colors.orange)),
                  
                  _buildModuleIcon(Icons.assignment_ind, "দায়িত্ব", Colors.purple),
                  _buildModuleIcon(Icons.pie_chart, "শেয়ার", Colors.deepPurple),
                  _buildModuleIcon(Icons.bar_chart, "রিপোর্ট", Colors.indigo),
                  _buildModuleIcon(Icons.fastfood, "ফান্ড", Colors.blueAccent),
                  _buildModuleIcon(Icons.menu_book, "খতিয়ান", Colors.orangeAccent),
                  _buildModuleIcon(Icons.account_balance, "ব্যাংক", Colors.lightBlue),
                  _buildModuleIcon(Icons.receipt, "ভাউচার", Colors.blue),
                  _buildModuleIcon(Icons.fact_check, "অনুমোদন", Colors.green),
                  _buildModuleIcon(Icons.point_of_sale, "ক্যাশ ক্রজিং", Colors.orange),
                  _buildModuleIcon(Icons.campaign, "নোটিশ", Colors.deepOrange),
                  _buildModuleIcon(Icons.inventory, "স্টক", Colors.purple),
                  _buildModuleIcon(Icons.people_outline, "পরিচালক", Colors.blue),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("সাম্প্রতিক লেনদেন", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey))),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: recentTransactions.isEmpty
                  ? const Center(child: Text("কোনো লেনদেন নেই"))
                  : Column(
                      children: recentTransactions.map((tx) {
                        bool isDeposit = tx['Type'] == 'জমা';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isDeposit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              child: Icon(isDeposit ? Icons.arrow_downward : Icons.arrow_upward, color: isDeposit ? Colors.green : Colors.red),
                            ),
                            title: Text(tx['Type'].toString(), style: TextStyle(fontWeight: FontWeight.bold, color: isDeposit ? Colors.green : Colors.red)),
                            subtitle: Text("${tx['MemberName']} | ${tx['Date'].toString().split(' ')[0]}"),
                            trailing: Text("৳ ${tx['Amount']}", style: TextStyle(fontWeight: FontWeight.bold, color: isDeposit ? Colors.green : Colors.red)),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String amount, IconData icon, Color color) {
    return Container(
      height: 100, padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20)),
        const SizedBox(height: 8),
        FittedBox(child: Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey))),
        const SizedBox(height: 4),
        FittedBox(child: Text(amount, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color))),
      ]),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, Color color, String type) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          // 🔥 বিনিয়োগ বাটনে ক্লিক করলে সরাসরি বিনিয়োগ পেজে যাবে
          if (type == "বিনিয়োগ") {
             await Navigator.push(context, MaterialPageRoute(builder: (c) => InvestmentScreen(userRole: userRole)));
          } else {
             // জমা, খরচ, আয় এর জন্য লিস্ট পেজে যাবে
             await Navigator.push(context, MaterialPageRoute(builder: (c) => TransactionListScreen(type: type)));
          }
          fetchDashboardData(); 
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5), padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 5),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ]),
        ),
      ),
    );
  }

  Widget _buildModuleIcon(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 28)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}