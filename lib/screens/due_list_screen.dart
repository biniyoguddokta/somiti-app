import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DueListScreen extends StatefulWidget {
  const DueListScreen({super.key});

  @override
  State<DueListScreen> createState() => _DueListScreenState();
}

class _DueListScreenState extends State<DueListScreen> {
  List<dynamic> dueList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDues();
  }

  void _fetchDues() async {
    setState(() => isLoading = true);
    var response = await ApiService.getTransactions();
    if (response is List) {
      setState(() {
        // শুধু বকেয়া এবং Unpaid গুলো ফিল্টার করা
        dueList = response.where((tx) => tx['Type'] == 'বকেয়া' && tx['Status'] == 'Unpaid').toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _payDue(String rowIndex, String amount) async {
    setState(() => isLoading = true);
    // পেমেন্ট স্ট্যাটাস আপডেট
    var res = await ApiService.updateTransactionStatus(rowIndex: rowIndex, status: 'Paid');
    if (res['status'] == 'success') {
      // জমা হিসেবে নতুন এন্ট্রি
      await ApiService.addTransaction(type: 'জমা', amount: amount, note: 'বকেয়া পরিশোধ', memberName: 'System', status: 'Paid');
      _fetchDues();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("বকেয়া পরিশোধ সফল হয়েছে!"), backgroundColor: Colors.green));
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("বকেয়া তালিকা"), backgroundColor: const Color(0xFFE53935), foregroundColor: Colors.white),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dueList.isEmpty
              ? const Center(child: Text("কোনো বকেয়া নেই!"))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: dueList.length,
                  itemBuilder: (context, index) {
                    var due = dueList[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.warning, color: Colors.white)),
                        title: Text(due['MemberName'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("তারিখ: ${due['Date'].toString().split(' ')[0]}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("৳ ${due['Amount']}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 10)),
                              onPressed: () => _payDue(due['RowIndex'].toString(), due['Amount'].toString()),
                              child: const Text("পরিশোধ", style: TextStyle(color: Colors.white, fontSize: 12)),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}