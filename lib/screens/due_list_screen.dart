import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        // 🔥 Status: Unpaid (বকেয়া বা বিলম্ব ফী) সবগুলো ফিল্টার করা হলো
        dueList = response.where((tx) => tx['Status'] == 'Unpaid').toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _payDue(String rowIndex, String amount, String memberName, String type) async {
    setState(() => isLoading = true);
    
    var res = await ApiService.updateTransactionStatus(rowIndex: rowIndex, status: 'Paid');
    
    if (res['status'] == 'success' || (res['status'] == 'error' && res['message'].contains("302"))) {
      // পেমেন্ট শেষে ট্রানজেকশনে জমা হিসেবে যুক্ত হবে
      await ApiService.addTransaction(
        type: 'জমা', 
        amount: amount, 
        note: '$type পরিশোধ', 
        memberName: memberName, 
        status: 'Paid',
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        paymentMethod: 'HAND CASH', 
      );
      _fetchDues();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("পরিশোধ সফল হয়েছে!"), backgroundColor: Colors.green));
    } else {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("পরিশোধ করতে সমস্যা হয়েছে!"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("বকেয়া ও বিলম্ব ফী"), backgroundColor: const Color(0xFFE53935), foregroundColor: Colors.white),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dueList.isEmpty
              ? const Center(child: Text("কোনো বকেয়া নেই!"))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: dueList.length,
                  itemBuilder: (context, index) {
                    var due = dueList[index];
                    String mName = due['MemberName'].toString();
                    String type = due['Type'].toString();
                    
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: type == 'বিলম্ব ফী' ? Colors.orange : Colors.red, 
                          child: Icon(type == 'বিলম্ব ফী' ? Icons.timer : Icons.warning, color: Colors.white)
                        ),
                        title: Text("$mName ($type)", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("তারিখ: ${due['Date'].toString().split(' ')[0]}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("৳ ${due['Amount']}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 10)),
                              onPressed: () => _payDue(due['RowIndex'].toString(), due['Amount'].toString(), mName, type),
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