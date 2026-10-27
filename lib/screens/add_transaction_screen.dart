import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
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
  final _dateController = TextEditingController(); // নতুন ডেট ফিল্ড
  
  bool _isLoading = false;
  String _status = "Paid"; 
  
  String userName = "";
  String userRole = "";
  String? _selectedMember;
  List<dynamic> members = [];
  bool _isFetchingMembers = true;

  @override
  void initState() {
    super.initState();
    // আজকের তারিখ ডিফল্ট সেট করা হলো
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadUserData();
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName') ?? "Unknown";
    userRole = prefs.getString('userRole') ?? "Member";

    if (userRole == 'Admin') {
      var res = await ApiService.getAllMembers();
      if (res is List) {
        setState(() { members = res; _isFetchingMembers = false; });
      } else {
        setState(() => _isFetchingMembers = false);
      }
    } else {
      setState(() { _selectedMember = userName; _isFetchingMembers = false; });
    }
  }

  // ডেট পিকার ফাংশন
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF00796B)),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
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
      memberName: _selectedMember!, 
      status: _status, 
      date: _dateController.text, // ডেট পাঠানো হলো
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
        : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
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

              // 🔥 ডেট সিলেক্ট অপশন
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: InputDecoration(
                  labelText: "তারিখ", 
                  prefixIcon: const Icon(Icons.calendar_today), 
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))
                ),
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