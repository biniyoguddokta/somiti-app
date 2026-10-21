import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  int _currentBanner = 0;
  final List<String> banners = [
    'https://via.placeholder.com/600x200/FFC107/000000?text=Special+Offer',
    'https://via.placeholder.com/600x200/00796B/FFFFFF?text=Somiti+Keeper+Pro',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= ৪ নং স্ক্রিনশট এর ডিজাইন =================
            
            const Text("SMS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSmsIcon(Icons.sms, "SMS ক্রেডিট", const Color(0xFF43A047)),
                _buildSmsIcon(Icons.chat_bubble_outline, "SMS টেম্পলেট", Colors.blue),
                _buildSmsIcon(Icons.campaign, "বাংক SMS", Colors.orange),
                _buildSmsIcon(Icons.history, "SMS ইতিহাস", Colors.teal),
              ],
            ),
            const SizedBox(height: 30),

            const Text("চার্ট ও বিশ্লেষণ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 15),
            Container(
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
            const SizedBox(height: 30),

            // ================= ৫ নং স্ক্রিনশট এর ডিজাইন =================

            const Text("সেটিংস, শেখা ও সাহায্য", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildSettingsCard(Icons.settings, "অ্যাপ সেটিংস", "শব্দ ও কম্পন", Colors.teal)),
                const SizedBox(width: 15),
                Expanded(child: _buildSettingsCard(Icons.settings_suggest, "উদ্যোক্তা সেটিংস", "ভাষা, দশমিক ও নিয়ম", Colors.green)),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildSettingsCard(Icons.play_circle_fill, "ভিডিও টিউটোরিয়াল", "দেখে দেখে শিখুন", Colors.red)),
                const SizedBox(width: 15),
                Expanded(child: _buildSettingsCard(Icons.menu_book, "নির্দেশিকা", "প্রতিটি পাতার ম্যানুয়াল", Colors.orange)),
              ],
            ),
            const SizedBox(height: 15),
            
            // হোম কাস্টমাইজ
            Container(
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
            const SizedBox(height: 15),
            
            // নতুন কিছু দরকার
            Container(
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
            const SizedBox(height: 25),

            // ব্যানার স্লাইডার
            CarouselSlider(
              options: CarouselOptions(
                height: 120,
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
            const SizedBox(height: 15),

            // ভাষা পরিবর্তন
            Container(
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
            const SizedBox(height: 20),
          ],
        ),
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