import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  final _dateController = TextEditingController();
  bool _isLoading = false;
  String _status = "Paid";
  
  String userName = "";
  String userRole = "";
  String? _selectedMember;
  String? _selectedPaymentMethod;
  String? _selectedSector;

  List<dynamic> members = [];
  bool _isFetchingMembers = true;
  
  File? _receiptImage;
  String _receiptBase64 = "";

  final List<String> paymentMethods = ["HAND CASH", "BANK ACCOUNT", "MFS ACCOUNT"];
  final List<String> sectors = ["কৃষি", "রিয়েল এস্টেট", "প্রযুক্তি", "শিক্ষা", "স্বাস্থ্যসেবা", "ব্যবসা"];

  @override
  void initState() {
    super.initState();
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

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030),
    );
    if (pickedDate != null) setState(() => _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate));
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (image != null) {
      File file = File(image.path);
      List<int> imageBytes = await file.readAsBytes();
      String base64String = base64Encode(imageBytes);
      setState(() {
        _receiptImage = file;
        _receiptBase64 = "data:image/jpeg;base64,$base64String";
      });
    }
  }

  void _submit() async {
    String amount = _amountController.text.trim();
    if (amount.isEmpty || _selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("টাকার পরিমাণ এবং সদস্য নির্বাচন করুন"), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoading = true);

    var response = await ApiService.addTransaction(
      type: widget.type, 
      amount: amount, 
      note: _noteController.text.trim(), 
      memberName: _selectedMember!, 
      status: _status, 
      date: _dateController.text, 
      paymentMethod: _selectedPaymentMethod ?? "HAND CASH",
    );
    
    setState(() => _isLoading = false);

    if (response['status'] == "success" || response['message'] == "Success" || response['message'] == "Saved") {
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
              if (userRole == 'Admin' && widget.type != "আয়") ...[
                DropdownButtonFormField<String>(
                  value: _selectedMember,
                  decoration: InputDecoration(labelText: "সদস্য নির্বাচন করুন", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                  items: members.map((m) => DropdownMenuItem(value: m['Name'].toString(), child: Text(m['Name'].toString()))).toList(),
                  onChanged: (val) => setState(() => _selectedMember = val),
                ),
                const SizedBox(height: 20),
              ],

              if (widget.type == "আয়") ...[
                DropdownButtonFormField<String>(
                  value: _selectedSector,
                  decoration: InputDecoration(labelText: "বিনিয়োগ খাত (সেক্টর) নির্বাচন করুন", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                  items: sectors.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setState(() { _selectedSector = val; _selectedMember = val; }),
                ),
                const SizedBox(height: 20),
              ],

              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "টাকার পরিমাণ (৳)", prefixIcon: const Icon(Icons.money), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              ),
              const SizedBox(height: 20),

              if (widget.type == "জমা") ...[
                DropdownButtonFormField<String>(
                  value: _selectedPaymentMethod,
                  decoration: InputDecoration(labelText: "পেমেন্ট মেথড (Payment Method)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                  items: paymentMethods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (val) => setState(() => _selectedPaymentMethod = val),
                ),
                const SizedBox(height: 20),
              ],

              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: InputDecoration(labelText: "তারিখ", prefixIcon: const Icon(Icons.calendar_today), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _noteController,
                decoration: InputDecoration(labelText: "বিবরণ / নোট (ঐচ্ছিক)", prefixIcon: const Icon(Icons.note), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              ),
              const SizedBox(height: 20),
              
              if (widget.type == "জমা") ...[
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 100, width: double.infinity,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(15), color: Colors.grey[200]),
                    child: _receiptImage != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_receiptImage!, fit: BoxFit.cover))
                        : const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, size: 40, color: Colors.grey), Text("রশিদের ছবি তুলুন (ঐচ্ছিক)", style: TextStyle(color: Colors.grey))])),
                  ),
                ),
                const SizedBox(height: 20),
              ],

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