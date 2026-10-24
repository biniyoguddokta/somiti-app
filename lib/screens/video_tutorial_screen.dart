import 'package:flutter/material.dart';

class VideoTutorialScreen extends StatelessWidget {
  const VideoTutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ডামি ভিডিও লিস্ট (পরে Apps Script থেকে আসবে)
    final List<Map<String, String>> videos = [
      {"title": "কিভাবে সদস্য যোগ করবেন", "link": "https://youtube.com"},
      {"title": "কিভাবে জমা ও খরচ লিখবেন", "link": "https://youtube.com"},
      {"title": "বিনিয়োগ প্রজেক্ট তৈরি", "link": "https://youtube.com"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("ভিডিও টিউটোরিয়াল"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: Container(
                width: 100,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(image: NetworkImage('https://via.placeholder.com/100x70?text=Video'), fit: BoxFit.cover),
                ),
                child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 30)),
              ),
              title: Text(videos[index]['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("ভিডিও দেখতে ক্লিক করুন", style: TextStyle(color: Colors.grey)),
              onTap: () {
                // এখানে ভিডিও প্লেয়ার ওপেন করার লজিক বসবে
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ভিডিও প্লেয়ার শীঘ্রই যুক্ত হবে")));
              },
            ),
          );
        },
      ),
    );
  }
}