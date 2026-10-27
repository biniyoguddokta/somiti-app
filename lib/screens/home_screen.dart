import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; 
import 'package:marquee/marquee.dart';

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
import 'transaction_list_screen.dart';
import 'investment_screen.dart';
import 'committee_screen.dart'; 
import 'notice_screen.dart'; 
import 'bank_screen.dart'; 

// নতুন পেজ ইমপোর্ট
import 'app_settings_screen.dart';
import 'entrepreneur_settings_screen.dart';
import 'video_tutorial_screen.dart';
import 'guide_screen.dart';

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
  
  // মোট সম্পদ
  bool _isBalanceVisible = false;
  double totalAssets = 0.0;
  Timer? _balanceTimer;

  // ভাষা পরিবর্তন
  bool isBengali = true;

  double cashInHand = 0.0;
  double todayDeposit = 0.0;
  double todayExpense = 0.0;
  int totalTransactions = 0;
  List<dynamic> recentTransactions = [];
  
  // 🔥 নোটিশ আপডেট করা হলো
  String latestNotice = "বিনিয়োগ উদ্যেক্তা অ্যাপে স্বাগতম! নতুন আপডেট পেতে চোখ রাখুন।";

  final List<String> banners = [
    'assets/banner1.png',
    'assets/banner2.png',
    'assets/banner3.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
    fetchDashboardData(); 
  }

  @override
  void dispose() {
    _balanceTimer?.cancel();
    super.dispose();
  }

  void _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "User";
      userRole = prefs.getString('userRole') ?? "Member";
    });
  }

  void _toggleBalance() {
    setState(() => _isBalanceVisible = true);
    _balanceTimer?.cancel();
    _balanceTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isBalanceVisible = false);
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
      double tempTotalAssets = 0.0;

      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      for (var tx in response) {
        String type = tx['Type'].toString();
        double amount = double.tryParse(tx['Amount'].toString()) ?? 0.0;
        String dateStr = tx['Date'].toString();
        String status = tx['Status']?.toString() ?? 'Paid';

        // 🔥 মোট সম্পদ হিসাব (জমা + আয়) - (বিনিয়োগ + খরচ)
        if (status == 'Paid') {
          if (type == 'জমা' || type == 'আয়') {
             tempTotalAssets += amount;
          } else if (type == 'বিনিয়োগ' || type == 'খরচ') {
             tempTotalAssets -= amount;
          }
        }

        // হাতে নগদ হিসাব
        if (type == 'জমা' || type == 'আয়' || type == 'বিনিয়োগ') tempCash += amount;
        else if (type == 'খরচ') tempCash -= amount;

        // আজকের হিসাব
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
        totalAssets = tempTotalAssets;
        _isLoadingStats = false;
      });
    } else {
      setState(() => _isLoadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return RefreshIndicator(
      onRefresh: fetchDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ১. টপ বার
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Color(0xFF00796B), size: 30),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  
                  // মোট সম্পদ (৩ সেকেন্ড টাইমারসহ)
                  GestureDetector(
                    onTap: _toggleBalance,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                      decoration: BoxDecoration(
                        color: _isBalanceVisible ? Colors.white : Colors.grey.shade200, 
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: _isBalanceVisible ? [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)] : [],
                        border: Border.all(color: Colors.grey.shade300)
                      ),
                      child: Column(
                        children: [
                          Text("মোট সম্পদ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _isBalanceVisible ? const Color(0xFF00796B) : Colors.black54)),
                          if (_isBalanceVisible) ...[
                            const SizedBox(height: 4),
                            Text("৳ ${totalAssets.toStringAsFixed(0)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                          ]
                        ],
                      ),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.person, color: Color(0xFF00796B), size: 30),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const MoreScreen()));
                    },
                  ),
                ],
              ),
            ),
            
            // ২. স্লাইডিং ব্যানার
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    autoPlay: true, 
                    autoPlayInterval: const Duration(seconds: 3), 
                    enlargeCenterPage: false, 
                    viewportFraction: 1.0, 
                    padEnds: false,
                    onPageChanged: (index, reason) => setState(() => _currentBanner = index),
                  ),
                  items: banners.map((bannerUrl) => Builder(
                    builder: (context) => Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 2.0),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15), 
                        child: Image.asset(
                          bannerUrl, 
                          fit: BoxFit.fill, 
                          errorBuilder: (c, e, s) => Container(color: Colors.grey.shade300, child: const Center(child: Icon(Icons.image)))
                        )
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // ৩. নোটিশ স্ক্রল
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE0B2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  const Icon(Icons.campaign, color: Colors.deepOrange, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 20,
                      child: Marquee(
                        text: latestNotice,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                        scrollAxis: Axis.horizontal,
                        blankSpace: 50.0,
                        velocity: 50.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ৪. লাল বক্স (আরও ছোট করা হলো)
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => const DueListScreen()));
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5), // মার্জিন কমানো হলো
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), // প্যাডিং কমানো হলো
                decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: const [
                    Icon(Icons.lock_clock, color: Colors.white, size: 28), // আইকন ছোট
                    SizedBox(width: 15),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("সদস্য যাদের জমা বকেয়া আছে", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 3), Text("বকেয়া গুলো দেখতে ট্যাপ করুন", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    )),
                    Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),

            // ৫. শুভেচ্ছা
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(children: [
                Text("${getGreeting()}, ", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                Text("$userName ", style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold)),
              ]),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("বিনিয়োগ উদ্যোক্তা", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            
            // ৬. ৪টি কার্ড
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: _isLoadingStats 
                ? const Center(child: CircularProgressIndicator())
                : Row(children: [
                    Expanded(child: _buildInfoCard("হাতে নগদ", "৳ ${cashInHand.toStringAsFixed(0)}", Icons.account_balance_wallet, Colors.blue, isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInfoCard("আজকের জমা", "৳ ${todayDeposit.toStringAsFixed(0)}", Icons.arrow_downward, Colors.green, isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInfoCard("আজকের খরচ", "৳ ${todayExpense.toStringAsFixed(0)}", Icons.arrow_upward, Colors.orange, isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInfoCard("সব লেনদেন", "$totalTransactions টি", Icons.receipt_long, Colors.red, isDark)),
                  ]),
            ),
            const SizedBox(height: 20),
            
            // ৭. ৪টি অ্যাকশন বাটন
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
            
            // ৮. মডিউল ও ফিচার
            const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("মডিউল ও ফিচার", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey))),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GridView.count(
                crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 15, crossAxisSpacing: 15, childAspectRatio: 1,
                children: [
                  InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const MembersScreen())), borderRadius: BorderRadius.circular(15), child: _buildModuleIcon(Icons.people, "সদস্য", Colors.blue, isDark)),
                  if (userRole == 'Admin')
                    InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AddMemberScreen())), borderRadius: BorderRadius.circular(15), child: _buildModuleIcon(Icons.person_add, "সদস্য যোগ", Colors.green, isDark)),
                  InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => CommitteeScreen(userRole: userRole))), borderRadius: BorderRadius.circular(15), child: _buildModuleIcon(Icons.group, "কমিটি", Colors.orange, isDark)),
                  _buildModuleIcon(Icons.assignment_ind, "দায়িত্ব", Colors.purple, isDark),
                  _buildModuleIcon(Icons.pie_chart, "শেয়ার", Colors.deepPurple, isDark),
                  InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ReportScreen())), borderRadius: BorderRadius.circular(15), child: _buildModuleIcon(Icons.bar_chart, "রিপোর্ট", Colors.indigo, isDark)),
                  _buildModuleIcon(Icons.fastfood, "ফান্ড", Colors.blueAccent, isDark),
                  _buildModuleIcon(Icons.menu_book, "খতিয়ান", Colors.orangeAccent, isDark),
                  InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const BankScreen())), borderRadius: BorderRadius.circular(15), child: _buildModuleIcon(Icons.account_balance, "ব্যাংক", Colors.lightBlue, isDark)),
                  _buildModuleIcon(Icons.receipt, "ভাউচার", Colors.blue, isDark),
                  _buildModuleIcon(Icons.fact_check, "অনুমোদন", Colors.green, isDark),
                  _buildModuleIcon(Icons.point_of_sale, "ক্যাশ ক্রজিং", Colors.orange, isDark),
                  InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const NoticeScreen())), borderRadius: BorderRadius.circular(15), child: _buildModuleIcon(Icons.campaign, "নোটিশ", Colors.deepOrange, isDark)),
                  _buildModuleIcon(Icons.inventory, "স্টক", Colors.purple, isDark),
                  _buildModuleIcon(Icons.people_outline, "পরিচালক", Colors.blue, isDark),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ৯. সাম্প্রতিক লেনদেন
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
                          color: isDark ? Colors.grey[800] : Colors.white,
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

            // ================= SMS, চার্ট ও সেটিংস =================
            const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("SMS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey))),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _buildSmsIcon(Icons.sms, "SMS ক্রেডিট", const Color(0xFF43A047)),
                _buildSmsIcon(Icons.chat_bubble_outline, "SMS টেম্পলেট", Colors.blue),
                _buildSmsIcon(Icons.campaign, "বাংক SMS", Colors.orange),
                _buildSmsIcon(Icons.history, "SMS ইতিহাস", Colors.teal),
              ]),
            ),
            const SizedBox(height: 30),

            const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("চার্ট ও বিশ্লেষণ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey))),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Row(children: [Icon(Icons.show_chart, color: Color(0xFF00796B)), SizedBox(width: 10), Text("আদায় প্রবণতা", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
                    Row(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(color: const Color(0xFF00796B), borderRadius: BorderRadius.circular(20)), child: const Text("৭ দিন", style: TextStyle(color: Colors.white, fontSize: 12))),
                      const SizedBox(width: 10),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: const Text("৩০ দিন", style: TextStyle(color: Color(0xFF00796B), fontSize: 12))),
                    ])
                  ]),
                  const SizedBox(height: 60),
                  const Text("এই সময়ে কোনো আদায় নেই", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 60),
                ]),
              ),
            ),
            const SizedBox(height: 30),

            // 🔥 সেটিংস কার্ড (সমান সাইজ এবং ক্লিকেবল)
            const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("সেটিংস, শেখা ও সাহায্য", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey))),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(children: [
                Expanded(child: _buildSettingsCard(Icons.settings, "অ্যাপ সেটিংস", "শব্দ ও কম্পন", Colors.teal, isDark, () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const AppSettingsScreen()));
                })),
                const SizedBox(width: 15),
                Expanded(child: _buildSettingsCard(Icons.settings_suggest, "উদ্যোক্তা সেটিংস", "ভাষা, দশমিক ও নিয়ম", Colors.green, isDark, () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const EntrepreneurSettingsScreen()));
                })),
              ]),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(children: [
                Expanded(child: _buildSettingsCard(Icons.play_circle_fill, "ভিডিও টিউটোরিয়াল", "দেখে দেখে শিখুন", Colors.red, isDark, () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const VideoTutorialScreen()));
                })),
                const SizedBox(width: 15),
                Expanded(child: _buildSettingsCard(Icons.menu_book, "নির্দেশিকা", "প্রতিটি পাতার ম্যানুয়াল", Colors.orange, isDark, () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const GuideScreen()));
                })),
              ]),
            ),
            const SizedBox(height: 30),

            // 🔥 ভাষা পরিবর্তন (সবার শেষে)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
                child: Row(
                  children: [
                    const Icon(Icons.translate, color: Color(0xFF00796B)),
                    const SizedBox(width: 15),
                    const Expanded(child: Text("অ্যাপের ভাষা", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                    ToggleButtons(
                      borderRadius: BorderRadius.circular(20),
                      isSelected: [isBengali, !isBengali],
                      onPressed: (index) {
                        setState(() { isBengali = index == 0; });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isBengali ? "ভাষা পরিবর্তন করা হচ্ছে..." : "Changing language..."), duration: const Duration(seconds: 1))
                        );
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ================= কাস্টম উইজেটসমূহ =================

  Widget _buildInfoCard(String title, String amount, IconData icon, Color color, bool isDark) {
    return Container(
      height: 100, padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20)),
        const SizedBox(height: 8),
        FittedBox(child: Text(title, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.grey))),
        const SizedBox(height: 4),
        FittedBox(child: Text(amount, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color))),
      ]),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, Color color, String type) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          if (type == "বিনিয়োগ") {
             await Navigator.push(context, MaterialPageRoute(builder: (c) => InvestmentScreen(userRole: userRole)));
          } else {
             await Navigator.push(context, MaterialPageRoute(builder: (c) => AddTransactionScreen(type: type)));
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

  Widget _buildModuleIcon(IconData icon, String label, Color color, bool isDark) {
    return Container(
      decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 28)),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
      ]),
    );
  }

  Widget _buildSmsIcon(IconData icon, String label, Color color) {
    return Column(children: [
      Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: color, size: 30)),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildSettingsCard(IconData icon, String title, String subtitle, Color color, bool isDark, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white, 
          borderRadius: BorderRadius.circular(15), 
          border: Border.all(color: Colors.grey.shade200)
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}