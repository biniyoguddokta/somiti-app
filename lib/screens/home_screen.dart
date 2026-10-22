import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'members_screen.dart';
import 'add_member_screen.dart';
import 'more_screen.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomeContent(),
    const MembersScreen(),
    const Center(child: Text("কালেকশন পেজ (শীঘ্রই আসছে)")),
    const Center(child: Text("রিপোর্ট পেজ (শীঘ্রই আসছে)")),
    const MoreScreen(), // 🔥 'আরও' পেজ কানেক্ট করা হলো
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00796B),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
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
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentBanner = 0;
  String userName = "Admin";
  String userRole = "Member";

  final List<String> banners = [
    'https://via.placeholder.com/800x300/00796B/FFFFFF?text=Banner+1',
    'https://via.placeholder.com/800x300/F44336/FFFFFF?text=Banner+2',
  ];

  @override
  void initState() { super.initState(); _loadUser(); }

  void _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "User";
      userRole = prefs.getString('userRole') ?? "Member";
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // টপ আইকন
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
          
          // ব্যানার
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
          
          // লাল বক্স
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

          // ডাইনামিক নাম
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(children: [
              const Text("শুভ সকাল, ", style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text("$userName ", style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold)),
            ]),
          ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("বিনিয়োগ উদ্যোক্তা", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          
          // ৪টি কার্ড
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(children: [
              Expanded(child: _buildInfoCard("হাতে নগদ", "৳ ০", Icons.account_balance_wallet, Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoCard("আজকের জমা", "৳ ০", Icons.arrow_downward, Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoCard("আজকের খরচ", "৳ ০", Icons.arrow_upward, Colors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoCard("সব লেনদেন", "৳ ০", Icons.receipt_long, Colors.red)),
            ]),
          ),
          const SizedBox(height: 20),
          
          // ৪টি বাটন (এখন কাজ করবে)
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
          
          // মডিউল ও ফিচার
          const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("মডিউল ও ফিচার", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey))),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: GridView.count(
              crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 15, crossAxisSpacing: 15, childAspectRatio: 1,
              children: [
                InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const MembersScreen())), borderRadius: BorderRadius.circular(15), child: _buildModuleIcon(Icons.people, "সদস্য", Colors.blue)),
                
                // 🔥 সদস্য যোগ বাটন শুধু অ্যাডমিন দেখবে
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
        ],
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
        FittedBox(child: Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue))),
      ]),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, Color color, String type) {
    return Expanded(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => AddTransactionScreen(type: type))),
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