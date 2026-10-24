import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<dynamic> transactions = [];
  bool isLoading = true;
  
  // মোট হিসাব
  double totalDeposit = 0.0;
  double totalExpense = 0.0;
  double totalIncome = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() => isLoading = true);
    var res = await ApiService.getTransactions();
    if (res is List) {
      double tDeposit = 0.0;
      double tExpense = 0.0;
      double tIncome = 0.0;

      for (var tx in res) {
        double amount = double.tryParse(tx['Amount'].toString()) ?? 0.0;
        String type = tx['Type'].toString();
        
        if (type == 'জমা') tDeposit += amount;
        if (type == 'খরচ') tExpense += amount;
        if (type == 'আয়') tIncome += amount;
      }

      setState(() {
        transactions = res.reversed.toList();
        totalDeposit = tDeposit;
        totalExpense = tExpense;
        totalIncome = tIncome;
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
        title: const Text("সব কালেকশন"),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData)],
      ),
      body: Column(
        children: [
          // মোট কালেকশন কার্ড
          Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF00796B),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: const Color(0xFF00796B).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem("মোট জমা", totalDeposit, Colors.greenAccent),
                Container(width: 1, height: 40, color: Colors.white30),
                _buildSummaryItem("মোট খরচ", totalExpense, Colors.redAccent),
                Container(width: 1, height: 40, color: Colors.white30),
                _buildSummaryItem("মোট আয়", totalIncome, Colors.amberAccent),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : transactions.isEmpty
                    ? const Center(child: Text("কোনো লেনদেন পাওয়া যায়নি!"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          var tx = transactions[index];
                          String type = tx['Type'].toString();
                          Color color = Colors.blue;
                          if (type == 'জমা') color = Colors.green;
                          if (type == 'খরচ') color = Colors.red;
                          if (type == 'আয়') color = Colors.teal;

                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color.withOpacity(0.1),
                                child: Icon(Icons.money, color: color),
                              ),
                              title: Text("$type: ৳ ${tx['Amount']}", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                              subtitle: Text("${tx['MemberName']} | ${tx['Date'].toString().split(' ')[0]}"),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 5),
        Text("৳ ${amount.toStringAsFixed(0)}", style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}