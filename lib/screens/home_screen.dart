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

  // বটম নেভিগেশনের পেজগুলো
  final List<Widget> _pages = [
    const HomeContent(), // ০: হোম (এখানে ১,২,৩,৪,৫ সব থাকবে)
    const Center(child: Text("সদস্য পেজ (শীঘ্রই আসছে)")), // ১: সদস্য
    const Center(child: Text("কালেকশন পেজ (শীঘ্রই আসছে)")), // ২: কালেকশন
    const Center(child: Text("রিপোর্ট পেজ (শীঘ্রই আসছে)")), // ৩: রিপোর্ট
    const Center(child: Text("আরও পেজ (পরে তৈরি হবে)")), // ৪: আরও (পরে আপনার নির্দেশনা অনুযায়ী হবে)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
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
    );
  }
}

// ================= ড্যাশবোর্ডের মূল অংশ (স্ক্রিনশট ১ থেকে ৫) =================

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentBanner = 0;

  final List<String> banners = [
    'https://via.placeholder.com/600x200/FFC107/000000?text=Banner+1',
    'https://via.placeholder.com/600x200/00796B/FFFFFF?text=Banner+2',
    'https://via.placeholder.com/600x200/F44336/FFFFFF?text=Banner+3',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          
          // ২. স্লাইডিং ব্যানার
          CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
              height: 150,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              enlargeCenterPage: true,
              viewportFraction: 0.9,
              onPageChanged: (index, reason) {
                setState(() { _currentBanner = index; });
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
                      image: DecorationImage(image: NetworkImage(bannerUrl), fit: BoxFit.cover),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          
          // ডট ইন্ডিকেটর
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
          
          // ৩. লাল বকেয়া বক্স
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

          // ৪. শুভেচ্ছা
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
          
          // ৫. ৪টি কার্ড (সমান সাইজ নিশ্চিত করা হয়েছে)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(child: _buildInfoCard("হাতে নগদ", "৳ ০", Icons.account_balance_wallet, Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _buildInfoCard("আজকের জমা", "৳ ০", Icons.arrow_downward, Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: _buildInfoCard("আজকের খরচ", "৳ ০", Icons.arrow_upward, Colors.orange)),
                const SizedBox(width: 8),
                Expanded(child: _buildInfoCard("সব লেনদেন", "৳ ০", Icons.receipt_long, Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // ৬. ৪টি অ্যাকশন বাটন
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
          
          // ৭. মডিউল ও ফিচার (শেষের 'আরও' বাদ দেওয়া হলো)
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

          // ================= ৪ নং স্ক্রিনশট এর ডিজাইন (মডিউলের নিচে) =================
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text("SMS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSmsIcon(Icons.sms, "SMS ক্রেডিট", const Color(0xFF43A047)),
                _buildSmsIcon(Icons.chat_bubble_outline, "SMS টেম্পলেট", Colors.blue),
                _buildSmsIcon(Icons.campaign, "বাংক SMS", Colors.orange),
                _buildSmsIcon(Icons.history, "SMS ইতিহাস", Colors.teal),
              ],
            ),
          ),
          const SizedBox(height: 30),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text("চার্ট ও বিশ্লেষণ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.show_chart, color: Color(0xFF00796B)),
                          SizedBox(width: 10),
                          Text("আদায় প্রবণতা", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(color: const Color(0xFF00796B), borderRadius: BorderRadius.circular(20)),
                            child: const Text("৭ দিন", style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: const Text("৩০ দিন", style: TextStyle(color: Color(0xFF00796B), fontSize: 12)),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 60),
                  const Text("এই সময়ে কোনো আদায় নেই", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // ================= ৫ নং স্ক্রিনশট এর ডিজাইন =================

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text("সেটিংস, শেখা ও সাহায্য", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(child: _buildSettingsCard(Icons.settings, "অ্যাপ সেটিংস", "শব্দ ও কম্পন", Colors.teal)),
                const SizedBox(width: 15),
                Expanded(child: _buildSettingsCard(Icons.settings_suggest, "উদ্যোক্তা সেটিংস", "ভাষা, দশমিক ও নিয়ম", Colors.green)),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(child: _buildSettingsCard(Icons.play_circle_fill, "ভিডিও টিউটোরিয়াল", "দেখে দেখে শিখুন", Colors.red)),
                const SizedBox(width: 15),
                Expanded(child: _buildSettingsCard(Icons.menu_book, "নির্দেশিকা", "প্রতিটি পাতার ম্যানুয়াল", Colors.orange)),
              ],
            ),
          ),
          const SizedBox(height: 15),
          
          // হোম কাস্টমাইজ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                children: [
                  const Icon(Icons.grid_view, color: Colors.blueGrey),
                  const SizedBox(width: 15),
                  const Expanded(child: Text("হোম কাস্টমাইজ করুন", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  Text("সাজান / লুকান", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          
          // নতুন কিছু দরকার
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.orange),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("অ্যাপে নতুন কিছু দরকার?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("বলুন — কী যোগ হলে আপনার কাজ সহজ হবে", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),

          // ব্যানার স্লাইডার
          CarouselSlider(
            options: CarouselOptions(
              height: 120,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              enlargeCenterPage: true,
              viewportFraction: 0.9,
            ),
            items: banners.map((bannerUrl) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(image: NetworkImage(bannerUrl), fit: BoxFit.cover),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 15),

          // ভাষা পরিবর্তন
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                children: [
                  const Icon(Icons.translate, color: Color(0xFF00796B)),
                  const SizedBox(width: 15),
                  const Expanded(child: Text("অ্যাপের ভাষা", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    onPressed: () {},
                    child: const Text("বাংলা", style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    onPressed: () {},
                    child: const Text("English"),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ================= কাস্টম উইজেট =================

  // কার্ডের সাইজ সমান করার জন্য height: 100 ফিক্স করা হয়েছে
  Widget _buildInfoCard(String title, String amount, IconData icon, Color color) {
    return Container(
      height: 100, 
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20)),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
        ],
      ),
    );
  }

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

  Widget _buildSmsIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSettingsCard(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}