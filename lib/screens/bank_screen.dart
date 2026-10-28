import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BankScreen extends StatefulWidget {
  const BankScreen({super.key});

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  bool isLoading = true;
  double totalBank = 0.0;
  double totalMFS = 0.0;
  List<dynamic> bankTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() => isLoading = true);
    var res = await ApiService.getTransactions();
    if (res is List) {
      double tempBank = 0.0;
      double tempMFS = 0.0;
      List<dynamic> tempTx = [];

      for (var tx in res) {
        String type = tx['Type'].toString();
        String paymentMethod = tx['PaymentMethod']?.toString() ?? 'HAND CASH';
        double amount = double.tryParse(tx['Amount'].toString()) ?? 0.0;
        String status = tx['Status']?.toString() ?? 'Paid';

        if (status == 'Paid' && (type == 'জমা' || type == 'আয়')) {
          if (paymentMethod == 'BANK ACCOUNT') {
            tempBank += amount;
            tempTx.add(tx);
          } else if (paymentMethod == 'MFS ACCOUNT') {
            tempMFS += amount;
            tempTx.add(tx);
          }
        }
      }

      setState(() {
        totalBank = tempBank;
        totalMFS = tempMFS;
        bankTransactions = tempTx.reversed.toList();
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
        title: const Text("ব্যাংক ও MFS হিসাব"), 
        backgroundColor: const Color(0xFF00796B), 
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData)],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // মোট ব্যালেন্স কার্ড
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Expanded(child: _buildBalanceCard("ব্যাংক একাউন্ট", totalBank, Icons.account_balance, Colors.blue, isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildBalanceCard("MFS একাউন্ট", totalMFS, Icons.phone_android, Colors.orange, isDark)),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Align(alignment: Alignment.centerLeft, child: Text("ব্যাংক/MFS লেনদেনের ইতিহাস", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey))),
                ),
                Expanded(
                  child: bankTransactions.isEmpty
                      ? const Center(child: Text("কোনো লেনদেন পাওয়া যায়নি!"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: bankTransactions.length,
                          itemBuilder: (context, index) {
                            var tx = bankTransactions[index];
                            return Card(
                              color: isDark ? Colors.grey[800] : Colors.white,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.money, color: Colors.white)),
                                title: Text("জমা: ৳ ${tx['Amount']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                subtitle: Text("${tx['MemberName']} | ${tx['PaymentMethod']}"),
                                trailing: Text(tx['Date'].toString().split(' ')[0], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ),
                            );
                          },
                        ),
                )
              ],
            ),
    );
  }

  Widget _buildBalanceCard(String title, double amount, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 5),
          Text("৳ ${amount.toStringAsFixed(0)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}