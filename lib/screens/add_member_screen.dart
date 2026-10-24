import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  String _selectedRole = "Member";
  bool _isLoading = false;

  void _submitData() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String email = _emailController.text.trim();
    String pin = _pinController.text.trim();
    String designation = _designationController.text.trim();

    if (name.isEmpty || phone.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("নাম, ফোন এবং পিন অবশ্যই দিতে হবে!"), backgroundColor: Colors.orange),
      );
      return;
    }

    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    setState(() { _isLoading = true; });

    var response = await ApiService.addMember(
      name: name,
      phone: phone,
      email: email.isEmpty ? "N/A" : email,
      pin: pin,
      role: _selectedRole,
      designation: designation.isEmpty ? "সদস্য" : designation, // ডিফল্ট পদবি
    );

    setState(() { _isLoading = false; });

    if (response['status'] == "success" || response['status'] == "error" && response['message'].contains("302")) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("নতুন সদস্য সফলভাবে যোগ হয়েছে!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "সমস্যা হয়েছে"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("নতুন সদস্য যোগ করুন"),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("সদস্যের নাম *", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _nameController, decoration: _inputDecoration("পুরো নাম লিখুন", Icons.person)),
            const SizedBox(height: 20),
            
            const Text("মোবাইল নম্বর *", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: _inputDecoration("মোবাইল নম্বর দিন", Icons.phone)),
            const SizedBox(height: 20),

            const Text("পদবি (Designation)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _designationController, decoration: _inputDecoration("সভাপতি, ক্যাশিয়ার, সদস্য ইত্যাদি", Icons.work)),
            const SizedBox(height: 20),

            const Text("ইমেইল (ঐচ্ছিক)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: _inputDecoration("ইমেইল লিখুন", Icons.email)),
            const SizedBox(height: 20),

            const Text("পিন (৪ ডিজিট) *", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _pinController, keyboardType: TextInputType.number, maxLength: 4, decoration: _inputDecoration("গোপন পিন দিন", Icons.password)),
            const SizedBox(height: 10),

            const Text("রোল সিলেক্ট করুন", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedRole,
                  items: const [
                    DropdownMenuItem(value: "Member", child: Text("সাধারণ সদস্য (Member)")),
                    DropdownMenuItem(value: "Admin", child: Text("অ্যাডমিন (Admin)")),
                  ],
                  onChanged: (value) { setState(() { _selectedRole = value!; }); },
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: _isLoading ? null : _submitData,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("সেভ করুন", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    );
  }
}