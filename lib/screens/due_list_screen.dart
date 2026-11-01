import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class DueListScreen extends StatefulWidget {
  const DueListScreen({super.key});

  @override
  State<DueListScreen> createState() => _DueListScreenState();
}

class _DueListScreenState extends State<DueListScreen> {
  List<dynamic> groupedDues = [];
  bool isLoading = true;
  String userRole = "Member";

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchDues();
  }

  void _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => userRole = prefs.getString('userRole') ?? "Member");
  }

  // ইংরেজি মাসকে বাংলায় রূপান্তর
  String _getBengaliMonth(String yyyyMM) {
    if (yyyyMM.length < 7) return yyyyMM;
    List<String> months = [
      "জানুয়ারি", "ফেব্রুয়ারি", "মার্চ", "এপ্রিল", "মে", "জুন",
      "জুলাই", "আগস্ট", "সেপ্টেম্বর", "অক্টোবর", "নভেম্বর", "ডিসেম্বর"
    ];
    try {
      int month = int.parse(yyyyMM.substring(5, 7));
      String year = yyyyMM.substring(0, 4);
      return "${months[month - 1]} $year";
    } catch (e) {
      return yyyyMM;
    }
  }

  void _fetchDues() async {
    setState(() => isLoading = true);
    
    var membersRes = await ApiService.getAllMembers();
    var txRes = await ApiService.getTransactions();
    
    if (membersRes is List && txRes is List) {
      String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
      
      // মাস অনুযায়ী বকেয়া গ্রুপ করা
      Map<String, List<Map<String, dynamic>>> tempGrouped = {};

      // ১. ডাটাবেসে থাকা Unpaid বকেয়াগুলো খোঁজা (বিলম্ব ফী বাদ দিয়ে)
      for (var tx in txRes) {
        String type = tx['Type'].toString().trim();
        String status = tx['Status']?.toString().trim() ?? 'Paid';
        String dateStr = tx['Date'].toString().trim();
        String month = dateStr.length >= 7 ? dateStr.substring(0, 7) : currentMonth;

        if (status == 'Unpaid' && type == 'বকেয়া') {
          if (!tempGrouped.containsKey(month)) {
            tempGrouped[month] = [];
          }
          tempGrouped[month]!.add({
            "type": tx['Note'].toString().isEmpty ? "মাসিক চাঁদা" : tx['Note'].toString(),
            "name": tx['MemberName'].toString(),
            "amount": tx['Amount'].toString(),
            "rowIndex": tx['RowIndex'].toString()
          });
        }
      }

      // ২. এই মাসে কারা জমা দেয়নি তাদের খোঁজা
      List<String> paidThisMonth = [];
      for (var tx in txRes) {
        String type = tx['Type'].toString().trim();
        String status = tx['Status']?.toString().trim() ?? 'Paid';
        String dateStr = tx['Date'].toString().trim();
        
        if (dateStr.contains(currentMonth) && type == 'জমা' && status == 'Paid') {
          paidThisMonth.add(tx['MemberName'].toString().trim().toLowerCase());
        }
      }

      if (!tempGrouped.containsKey(currentMonth)) {
        tempGrouped[currentMonth] = [];
      }

      for (var mem in membersRes) {
        String mName = mem['Name'].toString().trim();
        if (mName.isEmpty) continue;

        if (!paidThisMonth.contains(mName.toLowerCase())) {
          bool alreadyAdded = tempGrouped[currentMonth]!.any((element) => element['name'] == mName);
          if (!alreadyAdded) {
            tempGrouped[currentMonth]!.add({
              "type": "মাসিক চাঁদা",
              "name": mName,
              "amount": "2000",
              "rowIndex": "" 
            });
          }
        }
      }

      // মাসগুলোকে বড় থেকে ছোট (নতুন থেকে পুরোনো) সাজানো
      var sortedMonths = tempGrouped.keys.toList()..sort((a, b) => b.compareTo(a));

      setState(() {
        groupedDues = sortedMonths.map((month) {
           return {
             "month": month,
             "dues": tempGrouped[month]!
           };
        }).toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  // পেমেন্ট কনফার্ম ডায়ালগ
  void _showConfirmPaymentDialog(String rowIndex, String amount, String memberName, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("নিশ্চিত করুন", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("আপনি কি $memberName এর $amount টাকা পেয়েছেন?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("বাতিল", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B)),
            onPressed: () {
              Navigator.pop(context); 
              _payDue(rowIndex, amount, memberName, type); 
            },
            child: const Text("কনফার্ম করুন", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _payDue(String rowIndex, String amount, String memberName, String type) async {
    setState(() => isLoading = true);
    
    if (rowIndex.isNotEmpty) {
       var res = await ApiService.updateTransactionStatus(rowIndex: rowIndex, status: 'Paid');
       if (res['status'] != 'success' && !res['message'].contains("302")) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("পরিশোধ করতে সমস্যা হয়েছে!"), backgroundColor: Colors.red));
          return;
       }
    }

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("বকেয়া তালিকা"), backgroundColor: const Color(0xFFE53935), foregroundColor: Colors.white),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupedDues.isEmpty
              ? const Center(child: Text("কোনো বকেয়া নেই!"))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: groupedDues.length,
                  itemBuilder: (context, index) {
                    var group = groupedDues[index];
                    String month = group['month'];
                    List<dynamic> dues = group['dues'];

                    if (dues.isEmpty) return const SizedBox.shrink();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.white,
                      child: ExpansionTile(
                        leading: const Icon(Icons.calendar_month, color: Color(0xFFE53935)),
                        title: Text(_getBengaliMonth(month), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFE53935))),
                        subtitle: Text("মোট ${dues.length} জনের বকেয়া"),
                        children: dues.map((due) {
                          return ListTile(
                            leading: const Icon(Icons.person, color: Colors.grey),
                            title: Text(due['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(due['type']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("৳ ${due['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                                if (userRole == 'Admin') ...[
                                   const SizedBox(width: 10),
                                   ElevatedButton(
                                     style: ElevatedButton.styleFrom(
                                       backgroundColor: Colors.green,
                                       padding: const EdgeInsets.symmetric(horizontal: 10),
                                     ),
                                     onPressed: () => _showConfirmPaymentDialog(due['rowIndex'], due['amount'], due['name'], due['type']),
                                     child: const Text("পরিশোধ", style: TextStyle(color: Colors.white, fontSize: 12)),
                                   )
                                ]
                              ]
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
    );
  }
}