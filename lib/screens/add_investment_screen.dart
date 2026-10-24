import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddInvestmentScreen extends StatefulWidget {
  const AddInvestmentScreen({super.key});

  @override
  State<AddInvestmentScreen> createState() => _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends State<AddInvestmentScreen> {
  final _projectNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _profitController = TextEditingController();
  String _selectedSector = "কৃষি ও কৃষি পণ্য";
  bool _isLoading = false;

  final List<String> sectors = [
    "কৃষি ও কৃষি পণ্য", "রিয়েল এস্টেট", "প্রযুক্তি ও স্টার্টআপ", 
    "শিক্ষা ও দক্ষতা উন্নয়ন", "স্বাস্থ্যসেবা", "ব্যবসা ও শিল্প"
  ];

  void _submit() async {
    if (_projectNameController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("প্রজেক্টের নাম ও টাকার পরিমাণ দিন"), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoading = true);
    var res = await ApiService.addInvestment(
      sector: _selectedSector,
      projectName: _projectNameController.text.trim(),
      investAmount: _amountController.text.trim(),
      startDate: _startDateController.text.trim().isEmpty ? "N/A" : _startDateController.text.trim(),
      endDate: _endDateController.text.trim().isEmpty ? "N/A" : _endDateController.text.trim(),
      profitAmount: _profitController.text.trim().isEmpty ? "0" : _profitController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (res['status'] == "success" || (res['status'] == "error" && res['message'].contains("302"))) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("বিনিয়োগ সফলভাবে যোগ হয়েছে!"), backgroundColor: Colors.green));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "সমস্যা"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("নতুন বিনিয়োগ"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedSector,
              decoration: InputDecoration(labelText: "খাত (Sector)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              items: sectors.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedSector = val!),
            ),
            const SizedBox(height: 15),
            TextField(controller: _projectNameController, decoration: InputDecoration(labelText: "প্রজেক্টের নাম", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
            const SizedBox(height: 15),
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "বিনিয়োগের পরিমাণ (৳)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: TextField(controller: _startDateController, decoration: InputDecoration(labelText: "শুরুর তারিখ", hintText: "2024-01-01", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _endDateController, decoration: InputDecoration(labelText: "শেষের তারিখ", hintText: "2024-12-31", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))))),
              ],
            ),
            const SizedBox(height: 15),
            TextField(controller: _profitController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "প্রত্যাশিত লাভ (ঐচ্ছিক)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("সেভ করুন", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}