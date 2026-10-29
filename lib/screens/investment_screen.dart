import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'add_investment_screen.dart';

class InvestmentScreen extends StatefulWidget {
  final String userRole;
  const InvestmentScreen({super.key, required this.userRole});

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

  // 🔥 প্রজেক্ট সম্পূর্ণ করার ডায়ালগ
  void _showCompleteDialog(String rowIndex, String currentProfit) {
    TextEditingController profitController = TextEditingController(text: currentProfit != "0" ? currentProfit : "");
    TextEditingController noteController = TextEditingController();
    TextEditingController dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("প্রজেক্ট সম্পূর্ণ করুন"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: profitController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "মোট লাভ (৳)"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: "সম্পূর্ণ হওয়ার তারিখ"),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context, 
                    initialDate: DateTime.now(), 
                    firstDate: DateTime(2020), 
                    lastDate: DateTime(2030)
                  );
                  if (picked != null) {
                    dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: "নোট (মেয়াদ, বিবরণ ইত্যাদি)"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("বাতিল")
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B)),
            onPressed: () async {
              if (profitController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("লাভের পরিমাণ দিন!"), backgroundColor: Colors.red));
                return;
              }
              
              Navigator.pop(context);
              setState(() => isLoading = true);
              
              var res = await ApiService.completeInvestment(
                rowIndex: rowIndex,
                profitAmount: profitController.text.trim(),
                completionDate: dateController.text,
                note: noteController.text.trim(),
              );

              if (res['status'] == "success" || res['message'] == "Success (302)") {
                _fetchData();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("প্রজেক্ট সম্পূর্ণ হয়েছে এবং লাভ আয়-তে যুক্ত হয়েছে!"), backgroundColor: Colors.green));
              } else {
                setState(() => isLoading = false);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "সমস্যা হয়েছে"), backgroundColor: Colors.red));
              }
            },
            child: const Text("সম্পূর্ণ করুন", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ট্যাব অনুযায়ী ডেটা ফিল্টার
    List<dynamic> filteredInvestments = investments.where((inv) {
      String status = inv['Status']?.toString() ?? 'সক্রিয়';
      return status == selectedTab;
    }).toList();

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
                          bool isActive = inv['Status'] == 'সক্রিয়';
                          
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
                                        decoration: BoxDecoration(
                                          color: isActive ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1), 
                                          borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Text(
                                          inv['Status'].toString(), 
                                          style: TextStyle(color: isActive ? Colors.green : Colors.blue, fontSize: 12)
                                        ),
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
                                  ),
                                  
                                  // 🔥 অ্যাডমিনের জন্য সম্পূর্ণ করার বাটন (শুধু সক্রিয় প্রজেক্টে দেখাবে)
                                  if (widget.userRole == 'Admin' && isActive) ...[
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange.shade50,
                                          foregroundColor: Colors.orange.shade800,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          side: BorderSide(color: Colors.orange.shade300)
                                        ),
                                        icon: const Icon(Icons.check_circle_outline, size: 18),
                                        label: const Text("সম্পূর্ণ হয়েছে"),
                                        onPressed: () => _showCompleteDialog(inv['RowIndex'].toString(), inv['ProfitAmount'].toString()),
                                      ),
                                    ),
                                  ]
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