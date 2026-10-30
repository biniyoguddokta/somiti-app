import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String userRole = "Member";
  
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedMember;
  String _status = "Unpaid"; 

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchData();
  }

  void _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => userRole = prefs.getString('userRole') ?? "Member");
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

    // 🔥 চেক করা হচ্ছে এই মাসে এই সদস্যের বিলম্ব ফী আগে দেওয়া হয়েছে কি না
    String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    bool alreadyPaid = lateFees.any((tx) => 
      tx['MemberName'].toString().trim() == _selectedMember!.trim() &&
      tx['Date'].toString().contains(currentMonth)
    );

    if (alreadyPaid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$_selectedMember এই মাসে ইতিমধ্যে বিলম্ব ফী দিয়েছেন!"), backgroundColor: Colors.red));
      return;
    }

    setState(() => isLoading = true);
    
    var res = await ApiService.addTransaction(
      type: 'বিলম্ব ফী',
      amount: _amountController.text.trim(),
      note: _noteController.text.trim().isEmpty ? 'বিলম্ব ফী' : _noteController.text.trim(),
      memberName: _selectedMember!,
      status: _status, 
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
                if (userRole == 'Admin')
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
                        DropdownButtonFormField<String>(
                          value: _status,
                          decoration: InputDecoration(labelText: "স্ট্যাটাস (Paid/Unpaid)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                          items: const [
                            DropdownMenuItem(value: "Paid", child: Text("পরিশোধিত (Paid)")),
                            DropdownMenuItem(value: "Unpaid", child: Text("বাকি (Unpaid)")),
                          ],
                          onChanged: (val) => setState(() => _status = val!),
                        ),
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
                            bool isPaid = fee['Status'] == 'Paid';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: Icon(Icons.warning, color: isPaid ? Colors.green : Colors.red),
                                title: Text(fee['MemberName'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(fee['Note'].toString()),
                                // 🔥 Paid হলে শুধু Paid এবং তারিখ দেখাবে, Unpaid থাকবে না
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("৳ ${fee['Amount']}", style: TextStyle(color: isPaid ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                                    if (isPaid) ...[
                                      const Text("Paid", style: TextStyle(fontSize: 10, color: Colors.green)),
                                      Text(fee['Date'].toString().split(' ')[0], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    ] else ...[
                                      const Text("Unpaid", style: TextStyle(fontSize: 10, color: Colors.red)),
                                    ]
                                  ],
                                ),
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