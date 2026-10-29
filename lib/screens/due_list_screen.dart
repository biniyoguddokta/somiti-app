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
    
    var membersRes = await ApiService.getAllMembers();
    var txRes = await ApiService.getTransactions();
    
    if (membersRes is List && txRes is List) {
      String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
      
      List<String> paidMembers = [];
      List<dynamic> explicitUnpaid = [];

      for (var tx in txRes) {
        String txName = tx['MemberName'].toString().trim().toLowerCase();
        String txType = tx['Type'].toString().trim();
        String txDate = tx['Date'].toString().trim();
        String txStatus = tx['Status']?.toString().trim() ?? 'Paid';

        if (txDate.contains(currentMonth) && txType == 'জমা' && txStatus == 'Paid') {
          paidMembers.add(txName);
        }
        
        if (txStatus == 'Unpaid') {
          explicitUnpaid.add(tx);
        }
      }

      List<dynamic> tempPending = [];
      
      // যারা এই মাসে জমা দেয়নি
      for (var mem in membersRes) {
        String mName = mem['Name'].toString().trim();
        String mLowerName = mName.toLowerCase();
        
        if (mLowerName.isEmpty) continue;

        if (!paidMembers.contains(mLowerName)) {
          tempPending.add({
            "type": "মাসিক চাঁদা",
            "name": mName,
            "amount": "2000",
            "date": currentMonth,
            "rowIndex": "" 
          });
        }
      }

      // যাদের সরাসরি Unpaid এন্ট্রি আছে (বিলম্ব ফী/বকেয়া)
      for (var unpaid in explicitUnpaid) {
         tempPending.add({
            "type": unpaid['Type'].toString(),
            "name": unpaid['MemberName'].toString(),
            "amount": unpaid['Amount'].toString(),
            "date": unpaid['Date'].toString().split(' ')[0],
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
                        // 🔥 এখানে শুধু টাকার পরিমাণ দেখাবে, কোনো বাটন থাকবে না
                        trailing: Text(
                          "৳ ${due['amount']}", 
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}