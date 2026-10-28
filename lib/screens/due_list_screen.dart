import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class DueListScreen extends StatefulWidget {
  const DueListScreen({super.key});

  @override
  State<DueListScreen> createState() => _DueListScreenState();
}

class _DueListScreenState extends State<DueListScreen> {
  List<dynamic> pendingList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDues();
  }

  void _fetchDues() async {
    setState(() => isLoading = true);
    
    // 🔥 সদস্য এবং লেনদেন দুটোই আনতে হবে
    var membersRes = await ApiService.getAllMembers();
    var txRes = await ApiService.getTransactions();
    
    if (membersRes is List && txRes is List) {
      String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
      
      List<String> paidMembers = [];
      List<dynamic> explicitUnpaid = [];

      // কে কে এই মাসে টাকা দিয়েছে এবং কোন কোন ট্রানজেকশন Unpaid আছে তা বের করা
      for (var tx in txRes) {
        String txName = tx['MemberName'].toString().trim();
        String txType = tx['Type'].toString();
        String txDate = tx['Date'].toString();
        String txStatus = tx['Status']?.toString() ?? 'Paid';

        if (txDate.contains(currentMonth) && txType == 'জমা' && txStatus == 'Paid') {
          paidMembers.add(txName);
        }
        
        if (txStatus == 'Unpaid') {
          explicitUnpaid.add(tx);
        }
      }

      // যারা এই মাসে জমা দেয়নি তাদের খুঁজে বের করা
      List<dynamic> tempPending = [];
      
      for (var mem in membersRes) {
        String mName = mem['Name'].toString().trim();
        // যদি এই মাসে না দিয়ে থাকে, তবে তাকে লিস্টে যোগ করা হবে
        if (!paidMembers.contains(mName)) {
          tempPending.add({
            "type": "মাসিক চাঁদা",
            "name": mName,
            "amount": "2000",
            "date": currentMonth,
            "rowIndex": "" // সরাসরি পরিশোধ করা যাবে না, আগে বকেয়া তৈরি করতে হবে
          });
        }
      }

      // যাদের সরাসরি Unpaid (বিলম্ব ফী/বকেয়া) এন্ট্রি আছে তাদের যোগ করা
      for (var unpaid in explicitUnpaid) {
         tempPending.add({
            "type": unpaid['Type'].toString(),
            "name": unpaid['MemberName'].toString(),
            "amount": unpaid['Amount'].toString(),
            "date": unpaid['Date'].toString().split('T')[0],
            "rowIndex": unpaid['RowIndex'].toString()
         });
      }

      setState(() {
        pendingList = tempPending;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _payDue(String rowIndex, String amount, String memberName, String type) async {
    if (rowIndex.isEmpty) {
      // যদি সরাসরি Unpaid এন্ট্রি না থাকে (মানে সে এই মাসে দেয়নি), তবে নতুন বকেয়া+পেমেন্ট তৈরি করতে হবে
      setState(() => isLoading = true);
      await ApiService.addTransaction(
        type: 'জমা', 
        amount: amount, 
        note: '$type পরিশোধ (অটো)', 
        memberName: memberName, 
        status: 'Paid',
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        paymentMethod: 'HAND CASH', 
      );
      _fetchDues();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("পরিশোধ সফল হয়েছে!"), backgroundColor: Colors.green));
    } else {
      // যদি আগে থেকেই Unpaid থাকে (বিলম্ব ফী)
      setState(() => isLoading = true);
      var res = await ApiService.updateTransactionStatus(rowIndex: rowIndex, status: 'Paid');
      
      if (res['status'] == 'success' || res['message'].contains("302")) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("বকেয়া ও বিলম্ব ফী"), backgroundColor: const Color(0xFFE53935), foregroundColor: Colors.white),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pendingList.isEmpty
              ? const Center(child: Text("কোনো বকেয়া নেই! সবাই টাকা দিয়েছে।"))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: pendingList.length,
                  itemBuilder: (context, index) {
                    var due = pendingList[index];
                    String mName = due['name'];
                    String type = due['type'];
                    String rowIndex = due['rowIndex'];
                    
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
                        subtitle: Text("তারিখ: ${due['date']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("৳ ${due['amount']}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 10)),
                              onPressed: () => _payDue(rowIndex, due['amount'], mName, type),
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