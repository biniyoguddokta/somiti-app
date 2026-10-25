import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final String type; 
  const AddTransactionScreen({super.key, required this.type});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;
  String _status = "Paid"; 
  
  String userName = "";
  String userRole = "";
  String? _selectedMember; // ড্রপডাউনের জন্য
  List<dynamic> members = [];
  bool _isFetchingMembers = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName') ?? "Unknown";
    userRole = prefs.getString('userRole') ?? "Member";

    if (userRole == 'Admin') {
      // অ্যাডমিন হলে সদস্যদের লিস্ট আনবে
      var res = await ApiService.getAllMembers();
      if (res is List) {
        setState(() {
          members = res;
          _isFetchingMembers = false;
        });
      } else {
        setState(() => _isFetchingMembers = false);
      }
    } else {
      // সাধারণ সদস্য হলে তার নিজের নামই সেট হবে
      setState(() {
        _selectedMember = userName;
        _isFetchingMembers = false;
      });
    }
  }

  void _submit() async {
    String amount = _amountController.text.trim();
    String note = _noteController.text.trim();
    if (amount.isEmpty || _selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("টাকার পরিমাণ এবং সদস্য নির্বাচন করুন"), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoading = true);

    var response = await ApiService.addTransaction(
      type: widget.type, 
      amount: amount, 
      note: note, 
      memberName: _selectedMember!, // ড্রপডাউন থেকে সিলেক্ট করা নাম
      status: _status, 
    );
    
    setState(() => _isLoading = false);

    if (response['status'] == "success" || (response['status'] == "error" && response['message'].contains("302"))) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("সফলভাবে সেভ হয়েছে!"), backgroundColor: Colors.green));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? "সমস্যা"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.type} করুন"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: _isFetchingMembers 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // সদস্য সিলেক্ট ড্রপডাউন (শুধু অ্যাডমিন দেখবে)
              if (userRole == 'Admin') ...[
                DropdownButtonFormField<String>(
                  value: _selectedMember,
                  decoration: InputDecoration(labelText: "সদস্য নির্বাচন করুন", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                  items: members.map((m) => DropdownMenuItem(value: m['Name'].toString(), child: Text(m['Name'].toString()))).toList(),
                  onChanged: (val) => setState(() => _selectedMember = val),
                ),
                const SizedBox(height: 20),
              ],

              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "টাকার পরিমাণ (৳)", prefixIcon: const Icon(Icons.money), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(labelText: "বিবরণ / নোট (ঐচ্ছিক)", prefixIcon: const Icon(Icons.note), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              ),
              const SizedBox(height: 20),
              
              if (widget.type == "জমা" || widget.type == "বকেয়া") ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _status,
                      items: const [
                        DropdownMenuItem(value: "Paid", child: Text("পরিশোধিত (Paid)")),
                        DropdownMenuItem(value: "Unpaid", child: Text("বাকি (Unpaid)")),
                      ],
                      onChanged: (val) => setState(() => _status = val!),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B)),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("সেভ করুন", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              )
            ],
          ),
        ),
    );
  }
}