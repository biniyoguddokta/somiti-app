import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<dynamic> allTransactions = [];
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
        // নতুন লেনদেন আগে দেখানোর জন্য রিভার্স করা হলো
        allTransactions = res.reversed.toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("সব লেনদেনের হিস্ট্রি"), 
        backgroundColor: const Color(0xFF00796B), 
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData)
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allTransactions.isEmpty
              ? const Center(child: Text("কোনো লেনদেন পাওয়া যায়নি!"))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: allTransactions.length,
                  itemBuilder: (context, index) {
                    var tx = allTransactions[index];
                    String type = tx['Type'].toString();
                    bool isDeposit = type == 'জমা' || type == 'আয়';
                    Color color = isDeposit ? Colors.green : Colors.red;
                    IconData icon = isDeposit ? Icons.arrow_downward : Icons.arrow_upward;

                    if (type == 'বিনিয়োগ') { color = Colors.purple; icon = Icons.menu_book; }
                    else if (type == 'বিলম্ব ফী') { color = Colors.orange; icon = Icons.warning; }

                    return Card(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.1),
                          child: Icon(icon, color: color),
                        ),
                        title: Text(type, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("সদস্য: ${tx['MemberName']}"),
                            Text("বিবরণ: ${tx['Note'].toString().isEmpty ? 'নেই' : tx['Note']}", style: const TextStyle(fontSize: 12)),
                            Text("তারিখ: ${tx['Date'].toString().split(' ')[0]}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        trailing: Text(
                          "৳ ${tx['Amount']}", 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}