import 'package:flutter/material.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("নোটিশ বোর্ড"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Card(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.campaign, color: Colors.deepOrange),
              title: const Text("অ্যাপে স্বাগতম!", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("নতুন আপডেট পেতে চোখ রাখুন।"),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00796B),
        onPressed: () {
          // অ্যাডমিন নতুন নোটিশ অ্যাড করবে
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}