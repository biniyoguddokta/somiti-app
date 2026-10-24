import 'package:flutter/material.dart';
import '../services/api_service.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  List<dynamic> investments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() => isLoading = true);
    var res = await ApiService.getInvestments();
    if (res is List) {
      setState(() { investments = res; isLoading = false; });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("আমার বিনিয়োগ"),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}), // এডিট বাটন
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : investments.isEmpty
              ? const Center(child: Text("কোনো বিনিয়োগ পাওয়া যায়নি!"))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: investments.length,
                  itemBuilder: (context, index) {
                    var inv = investments[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(inv['ProjectName'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                  child: Text(inv['Status'].toString(), style: const TextStyle(color: Colors.green, fontSize: 12)),
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text("৳ ${inv['InvestAmount']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("মেয়াদ: ${inv['StartDate']} - ${inv['EndDate']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                Text("লাভ: ৳ ${inv['ProfitAmount']}", style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00796B),
        onPressed: () { /* Add Investment Screen */ },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}