import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_investment_screen.dart';

class InvestmentScreen extends StatefulWidget {
  final String userRole; // 🔥 এই লাইনটি নিশ্চিত করুন
  const InvestmentScreen({super.key, required this.userRole}); // 🔥 required this.userRole নিশ্চিত করুন

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  List<dynamic> investments = [];
  bool isLoading = true;
  String selectedTab = "সক্রিয়";

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
    List<dynamic> filteredInvestments = investments.where((inv) => (inv['Status']?.toString() ?? 'সক্রিয়') == selectedTab).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("আমার বিনিয়োগ"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                _buildTab("সক্রিয়"),
                _buildTab("সম্পন্ন"),
                _buildTab("বাতিল"),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredInvestments.isEmpty
                    ? const Center(child: Text("কোনো বিনিয়োগ পাওয়া যায়নি!"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: filteredInvestments.length,
                        itemBuilder: (context, index) {
                          var inv = filteredInvestments[index];
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
                                      Expanded(child: Text(inv['ProjectName'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                        child: Text(selectedTab, style: const TextStyle(color: Colors.green, fontSize: 12)),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(inv['Sector'].toString(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  const SizedBox(height: 10),
                                  Text("৳ ${inv['InvestAmount']}", style: const TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold, fontSize: 18)),
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
          ),
        ],
      ),
      floatingActionButton: widget.userRole == 'Admin' 
        ? FloatingActionButton(
            backgroundColor: const Color(0xFF00796B),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (c) => const AddInvestmentScreen()));
              _fetchData();
            },
            child: const Icon(Icons.add, color: Colors.white),
          )
        : null,
    );
  }

  Widget _buildTab(String title) {
    bool isSelected = selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? const Color(0xFF00796B) : Colors.transparent, borderRadius: BorderRadius.circular(15)),
          child: Center(child: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
}