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
      const Center(child: Text("রিপোর্ট পেজ (শীঘ্রই আসছে)")),
      const MoreScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00796B),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if(index == 0) {
            _homeKey.currentState?.fetchDashboardData();
          }
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

  // ড্যাশবোর্ডের হিসাবের ভ্যারিয়েবল
  double cashInHand = 0.0;
  double todayDeposit = 0.0;
  double todayExpense = 0.0;
  int totalTransactions = 0;

  final List<String> banners = [
    'https://via.placeholder.com/800x300/00796B/FFFFFF?text=Banner+1',
    'https://via.placeholder.com/800x300/F44336/FFFFFF?text=Banner+2',
    'https://via.placeholder.com/800x300/113/FFC107/000000?text=Banner+3',
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

  // 🔥 সময় অনুযায়ী শুভেচ্ছা বের করার ফাংশন
  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "শুভ সকাল"; // সকাল ৫টা থেকে দুপুর ১২টা
    } else if (hour >= 12 && hour < 16) {
      return "শুভ দুপুর"; // দুপুর ১২টা থেকে বিকাল ৪টা
    } else if (hour >= 16 && hour < 18) {
      return "শুভ বিকাল"; // বিকাল ৪টা থেকে সন্ধ্যা ৬টা
    } else if (hour >= 18 && hour < 20) {
      return "শুভ সন্ধ্যা"; // সন্ধ্যা ৬টা থেকে রাত ৮টা
    } else {
      return "শুভ রাত্রি"; // রাত ৮টা থেকে ভোর ৫টা
    }
  }

  Future<void> fetchDashboardData() async {
    setState(() => _isLoadingStats = true);
    var response = await ApiService.getTransactions();
    
    if (response is List) {
      double tempCash = 0.0;
      double tempTodayDeposit = 0.0;
      double tempTodayExpense = 0.0;
      int tempTotalTx = response.length;

      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      for (var tx in response) {
        String type = tx['Type'].toString();
        double amount = double.tryParse(tx['Amount'].toString()) ?? 0.0;
        String dateStr = tx['Date'].toString();

        if (type == 'জমা' || type == 'আয়' || type == 'বিনিয়োগ') {
          tempCash += amount;
        } else if (type == 'খরচ') {
          tempCash -= amount;
        }

        if (dateStr.contains(todayDate)) {
          if (type == 'জমা') tempTodayDeposit += amount;
          if (type == 'খরচ') tempTodayExpense += amount;
        }
      }

      setState(() {
        cashInHand = tempCash;
        todayDeposit = tempTodayDeposit;
        todayExpense = tempTodayExpense;
        totalTransactions = tempTotalTx;
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
            // ১. টপ আইকন
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.menu, color: Color(0xFF00796B), size: 30),
                  Row(
                    children: const [
                      Icon(Icons.person, color: Color(0xFF00796B)), SizedBox(width: 15),
                      Icon(Icons.headset_mic, color: Color(0xFF00796B)), SizedBox(width: 15),
                      Icon(Icons.notifications, color: Color(0xFF00796B)), SizedBox(width: 15),
                      Icon(Icons.help_outline, color: Color(0xFF00796B)),
                    ],
                  )
                ],
              ),
            ),
            
            // ২. স্লাইডিং ব্যানার
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
            
            // ৩. লাল বক্স
            Container(
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

            // ৪. ডাইনামিক শুভেচ্ছা (এখন সময় অনুযায়ী পরিবর্তন হবে)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(children: [
                Text("${getGreeting()}, ", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                Text("$userName ", style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold)),
              ]),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("বিনিয়োগ উদ্যোক্তা", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            
            // ৫. ৪টি কার্ড
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
            
            // ৬. ৪টি অ্যাকশন বাটন
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
            
            // ৭. মডিউল ও ফিচার
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
                  _buildModuleIcon(Icons.group, "কমিটি", Colors.orange),
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

            // ================= স্ক্রিনশট ৪ (SMS ও চার্ট) =================
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
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
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

            // ================= স্ক্রিনশট ৫ (সেটিংস ও ভাষা) =================
            const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("সেটিংস, শেখা ও সাহায্য", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey))),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(children: [
                Expanded(child: _buildSettingsCard(Icons.settings, "অ্যাপ সেটিংস", "শব্দ ও কম্পন", Colors.teal)),
                const SizedBox(width: 15),
                Expanded(child: _buildSettingsCard(Icons.settings_suggest, "উদ্যোক্তা সেটিংস", "ভাষা, দশমিক ও নিয়ম", Colors.green)),
              ]),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(children: [
                Expanded(child: _buildSettingsCard(Icons.play_circle_fill, "ভিডিও টিউটোরিয়াল", "দেখে দেখে শিখুন", Colors.red)),
                const SizedBox(width: 15),
                Expanded(child: _buildSettingsCard(Icons.menu_book, "নির্দেশিকা", "প্রতিটি পাতার ম্যানুয়াল", Colors.orange)),
              ]),
            ),
            const SizedBox(height: 25),

            SizedBox(
              height: 120,
              child: CarouselSlider(
                options: CarouselOptions(autoPlay: true, autoPlayInterval: const Duration(seconds: 3), enlargeCenterPage: true, viewportFraction: 0.9),
                items: banners.map((bannerUrl) => Builder(
                  builder: (context) => Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(bannerUrl, fit: BoxFit.fill, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image)))),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ================= কাস্টম উইজেটস =================

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
          await Navigator.push(context, MaterialPageRoute(builder: (c) => AddTransactionScreen(type: type)));
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

  Widget _buildSmsIcon(IconData icon, String label, Color color) {
    return Column(children: [
      Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: color, size: 30)),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildSettingsCard(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ])),
      ]),
    );
  }
}