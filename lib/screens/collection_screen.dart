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
        transactions = res.reversed.toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("সব লেনদেন"),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData)],
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
                    String type = tx['Type'].toString();
                    Color color = Colors.blue;
                    IconData icon = Icons.money;
                    if (type == 'জমা') { color = Colors.green; icon = Icons.arrow_downward; }
                    else if (type == 'খরচ') { color = Colors.red; icon = Icons.arrow_upward; }
                    else if (type == 'আয়') { color = Colors.teal; icon = Icons.savings; }
                    else if (type == 'বিনিয়োগ') { color = Colors.purple; icon = Icons.menu_book; }

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
                        title: Text("$type: ৳ ${tx['Amount']}", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("বিবরণ: ${tx['Note'].toString().isEmpty ? 'নেই' : tx['Note']}"),
                            Text("সদস্য: ${tx['MemberName']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            Text("তারিখ: ${tx['Date'].toString().split(' ')[0]}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}