import 'package:flutter/material.dart';

class MeetingScreen extends StatelessWidget {
  const MeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("সভা সমূহ"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Card(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.calendar_month, color: Color(0xFF00796B)),
              title: const Text("সাধারণ সভা", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("তারিখ: ২০২৪-০৫-১০"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00796B),
        onPressed: () {
          // সভা যোগ করার ডায়ালগ বা পেজ
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}