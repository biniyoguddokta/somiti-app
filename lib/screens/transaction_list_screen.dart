import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  final String type; // 'জমা', 'খরচ', 'আয়'
  const TransactionListScreen({super.key, required this.type});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  List<dynamic> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() => isLoading = true);
    var res = await ApiService.getTransactions();
    if (res is List) {
      setState(() {
        // শুধু নির্দিষ্ট টাইপের লেনদেন ফিল্টার করা
        transactions = res.where((tx) => tx['Type'].toString() == widget.type).toList().reversed.toList();
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
      appBar: AppBar(
        title: Text("${widget.type} এর তালিকা"),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? const Center(child: Text("কোনো লেনদেন পাওয়া যায়নি!"))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    var tx = transactions[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF00796B).withOpacity(0.1),
                          child: const Icon(Icons.money, color: Color(0xFF00796B)),
                        ),
                        title: Text(tx['MemberName'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${tx['Note']} | ${tx['Date'].toString().split(' ')[0]}"),
                        trailing: Text(
                          "৳ ${tx['Amount']}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF00796B)),
                        ),
                      ),
                    );
                  },
                ),
      // 🔥 নতুন এন্ট্রি করার জন্য প্লাস বাটন
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00796B),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (c) => AddTransactionScreen(type: widget.type)));
          _fetchData(); // এন্ট্রি শেষে লিস্ট রিফ্রেশ হবে
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}