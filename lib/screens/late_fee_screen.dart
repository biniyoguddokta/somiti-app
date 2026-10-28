import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class LateFeeScreen extends StatefulWidget {
  const LateFeeScreen({super.key});

  @override
  State<LateFeeScreen> createState() => _LateFeeScreenState();
}

class _LateFeeScreenState extends State<LateFeeScreen> {
  List<dynamic> lateFees = [];
  List<dynamic> members = [];
  bool isLoading = true;
  
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedMember;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() => isLoading = true);
    var res = await ApiService.getTransactions();
    var memRes = await ApiService.getAllMembers();
    
    if (res is List && memRes is List) {
      setState(() {
        lateFees = res.where((tx) => tx['Type'] == 'বিলম্ব ফী').toList().reversed.toList();
        members = memRes;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _addLateFee() async {
    if (_selectedMember == null || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("সদস্য এবং পরিমাণ নির্বাচন করুন"), backgroundColor: Colors.orange));
      return;
    }

    setState(() => isLoading = true);
    
    // 🔥 এখানে paymentMethod যুক্ত করা হলো
    var res = await ApiService.addTransaction(
      type: 'বিলম্ব ফী',
      amount: _amountController.text.trim(),
      note: _noteController.text.trim().isEmpty ? 'বিলম্ব ফী' : _noteController.text.trim(),
      memberName: _selectedMember!,
      status: 'Unpaid',
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      paymentMethod: 'HAND CASH', 
    );
    
    setState(() => isLoading = false);

    if (res['status'] == "success" || (res['status'] == "error" && res['message'].contains("302"))) {
      _amountController.clear();
      _noteController.clear();
      _fetchData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("বিলম্ব ফী যোগ হয়েছে!"), backgroundColor: Colors.green));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "সমস্যা"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("বিলম্ব ফী"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  color: Colors.white,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: "সদস্য নির্বাচন করুন", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                        value: _selectedMember,
                        items: members.map((m) => DropdownMenuItem(value: m['Name'].toString(), child: Text(m['Name'].toString()))).toList(),
                        onChanged: (val) => setState(() => _selectedMember = val),
                      ),
                      const SizedBox(height: 10),
                      TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "পরিমাণ (৳)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                      const SizedBox(height: 10),
                      TextField(controller: _noteController, decoration: InputDecoration(labelText: "কারণ / নোট", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B)),
                          onPressed: _addLateFee,
                          child: const Text("যোগ করুন", style: TextStyle(color: Colors.white)),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: lateFees.isEmpty
                      ? const Center(child: Text("কোনো বিলম্ব ফী নেই"))
                      : ListView.builder(
                          padding: const EdgeInsets.all(15),
                          itemCount: lateFees.length,
                          itemBuilder: (context, index) {
                            var fee = lateFees[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const Icon(Icons.warning, color: Colors.red),
                                title: Text(fee['MemberName'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(fee['Note'].toString()),
                                trailing: Text("৳ ${fee['Amount']}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
                )
              ],
            ),
    );
  }
}