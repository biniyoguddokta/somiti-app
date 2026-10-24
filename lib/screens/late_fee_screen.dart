import 'package:flutter/material.dart';

class LateFeeScreen extends StatelessWidget {
  const LateFeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("বিলম্ব ফী"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: const Center(child: Text("বিলম্ব ফী এর লিস্ট ও এড করার অপশন শীঘ্রই আসছে")),
    );
  }
}