import 'package:flutter/material.dart';

class BankScreen extends StatelessWidget {
  const BankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ব্যাংক হিসাব"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Card(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.blue),
              title: const Text("ডাচ-বাংলা ব্যাংক", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("হিসাব নং: 123456789"),
              trailing: const Text("৳ ৫০,০০০", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00796B),
        onPressed: () {
          // অ্যাডমিন নতুন ব্যাংক অ্যাড করবে
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}