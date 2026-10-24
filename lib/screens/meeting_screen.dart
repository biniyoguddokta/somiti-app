import 'package:flutter/material.dart';

class MeetingScreen extends StatelessWidget {
  const MeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("সভা"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: const Center(child: Text("সভার তালিকা ও হাজিরা শীঘ্রই আসছে")),
    );
  }
}