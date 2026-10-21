import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final CarouselController _carouselController = CarouselController();
  int _currentBanner = 0;

  // ব্যানার ইমেজের লিস্ট (পরে assets/ যোগ করবেন)
  final List<String> banners = [
    'https://via.placeholder.com/600x200/FFC107/000000?text=Banner+1',
    'https://via.placeholder.com/600x200/00796B/FFFFFF?text=Banner+2',
    'https://via.placeholder.com/600x200/F44336/FFFFFF?text=Banner+3',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // বটম নেভিগেশন বার (ফিক্সড থাকবে)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00796B),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "হোম"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "সদস্য"),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: "কালেকশন"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "রিপোর্ট"),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "আরও"),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ১. টপ আইকন (স্ক্রল করলে উপরে চলে যাবে)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.menu, color: Color(0xFF00796B), size: 30),
                    Row(
                      children: const [
                        Icon(Icons.person, color: Color(0xFF00796B)),
                        SizedBox(width: 15),
                        Icon(Icons.headset_mic, color: Color(0xFF00796B)),
                        SizedBox(width: 15),
                        Icon(Icons.notifications, color: Color(0xFF00796B)),
                        SizedBox(width: 15),
                        Icon(Icons.help_outline, color: Color(0xFF00796B)),
                      ],
                    )
                  ],
                ),
              ),

              // ২. অটো স্লাইডিং ব্যানার (৩ সেকেন্ড পরপর)
              CarouselSlider(
                carouselController: _carouselController,
                options: CarouselOptions(
                  height: 150,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentBanner = index;
                    });
                  },
                ),
                items: banners.map((bannerUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: NetworkImage(bannerUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              
              // ব্যানার ডট ইন্ডিকেটর
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: banners.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _carouselController.animateToPage(entry.key),
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentBanner == entry.key ? const Color(0xFF00796B) : Colors.grey[300],
                      ),
                    ),
                  );
                }).toList(),
              ),

              // ৩. লাল এলার্ট বক্স
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock, color: Colors.white, size: 35),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("সদস্য যাদের জমা বকেয়া আছে", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 5),
                          Text("বকেয়া গুলো দেখতে ট্যাপ করুন", style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  ],
                ),
              ),

              // ৪. ডাইনামিক শুভেচ্ছা ও নাম
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: const [
                    Text("শুভ সকাল, ", style: TextStyle(fontSize: 16, color: Colors.grey)),
                    Text("Admin ", style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text("বিনিয়োগ উদ্যোক্তা", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),

              // ৫. ৪টি কার্ড (হাতে নগদ, আজকের জমা, আজকের খরচ, সব লেনদেন)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoCard("হাতে নগদ", "৳ ০", Icons.account_balance_wallet, Colors.blue),
                    _buildInfoCard("আজকের জমা", "৳ ০", Icons.arrow_downward, Colors.green),
                    _buildInfoCard("আজকের খরচ", "৳ ০", Icons.arrow_upward, Colors.orange),
                    _buildInfoCard("সব লেনদেন", "৳ ০", Icons.receipt_long, Colors.red),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ৬. অ্যাকশন বাটন (জমা, খরচ, আয়, বিনিয়োগ)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionButton("জমা", Icons.money, const Color(0xFF43A047)),
                    _buildActionButton("খরচ", Icons.shopping_bag, const Color(0xFFE53935)),
                    _buildActionButton("আয়", Icons.savings, const Color(0xFF00897B)),
                    _buildActionButton("বিনিয়োগ", Icons.menu_book, const Color(0xFF8E24AA)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // ৭. মডিউল ও ফিচার (পরিবর্তিত গ্রিড)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text("মডিউল ও ফিচার", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 1,
                  children: [
                    _buildModuleIcon(Icons.people, "সদস্য", Colors.blue),
                    _buildModuleIcon(Icons.person_add, "সদস্য যোগ", Colors.green),
                    _buildModuleIcon(Icons.group, "কমিটি", Colors.orange), // নাম পরিবর্তন
                    _buildModuleIcon(Icons.assignment_ind, "দায়িত্ব", Colors.purple), // নাম পরিবর্তন
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
                    _buildModuleIcon(Icons.grid_view, "আরও", Colors.grey), // টান সমিতি বাদ
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // কাস্টম কার্ড উইজেট
  Widget _buildInfoCard(String title, String amount, IconData icon, Color color) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20)),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 5),
          Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }

  // কাস্টম অ্যাকশন বাটন উইজেট
  Widget _buildActionButton(String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 5),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // কাস্টম মডিউল আইকন উইজেট
  Widget _buildModuleIcon(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}