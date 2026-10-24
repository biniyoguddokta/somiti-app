import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MemberProfileScreen extends StatefulWidget {
  final Map<String, dynamic> member;
  const MemberProfileScreen({super.key, required this.member});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  List<dynamic> memberTransactions = [];
  bool isLoading = true;
  double totalDeposit = 0.0;
  double totalDue = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchMemberData();
  }

  void _fetchMemberData() async {
    var response = await ApiService.getTransactions();
    
    if (response is List) {
      setState(() {
        memberTransactions = response.where((tx) => tx['MemberName'].toString() == widget.member['Name'].toString()).toList();
        
        // হিসাব বের করা
        totalDeposit = 0.0;
        totalDue = 0.0;
        for (var tx in memberTransactions) {
          double amount = double.tryParse(tx['Amount'].toString()) ?? 0.0;
          String type = tx['Type'].toString();
          String status = tx['Status']?.toString() ?? 'Paid';

          if (type == 'জমা' && status == 'Paid') totalDeposit += amount;
          if (type == 'বকেয়া' && status == 'Unpaid') totalDue += amount;
        }
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
        title: const Text("সদস্য প্রোফাইল"),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // প্রোফাইল হেডার
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF00796B),
                  child: Text(
                    widget.member['Name'].toString().substring(0, 1).toUpperCase(), 
                    style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.member['Name'].toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(widget.member['Phone'].toString(), style: const TextStyle(color: Colors.grey, fontSize: 16)),
                      Text(
                        widget.member['Designation']?.toString() ?? (widget.member['Role'] == 'Admin' ? "প্রতিষ্ঠাতা / অ্যাডমিন" : "সদস্য"), 
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          // সংক্ষিপ্ত হিসাব
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(child: _buildStatCard("মোট জমা", "৳ ${totalDeposit.toStringAsFixed(0)}", Colors.green)),
                const SizedBox(width: 15),
                Expanded(child: _buildStatCard("বকেয়া", "৳ ${totalDue.toStringAsFixed(0)}", Colors.red)),
              ],
            ),
          ),

          // লেনদেনের লিস্ট
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Align(alignment: Alignment.centerLeft, child: Text("লেনদেনের ইতিহাস", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : memberTransactions.isEmpty
                    ? const Center(child: Text("কোনো লেনদেন নেই"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: memberTransactions.length,
                        itemBuilder: (context, index) {
                          var tx = memberTransactions[index];
                          bool isDeposit = tx['Type'] == 'জমা';
                          bool isPaid = (tx['Status']?.toString() ?? 'Paid') == 'Paid';
                          
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: Icon(isDeposit ? Icons.arrow_downward : Icons.warning, color: isDeposit ? Colors.green : Colors.red),
                              title: Text(tx['Type'].toString(), style: TextStyle(fontWeight: FontWeight.bold, color: isDeposit ? Colors.green : Colors.red)),
                              subtitle: Text("তারিখ: ${tx['Date'].toString().split(' ')[0]}"),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("৳ ${tx['Amount']}", style: TextStyle(fontWeight: FontWeight.bold, color: isDeposit ? Colors.green : Colors.red)),
                                  Text(isPaid ? "পরিশোধিত" : "বাকি", style: TextStyle(fontSize: 12, color: isPaid ? Colors.green : Colors.red)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        border: Border.all(color: color.withOpacity(0.3))
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(amount, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}