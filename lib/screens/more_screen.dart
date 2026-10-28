import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../main.dart'; 
import 'login_screen.dart';
import 'app_settings_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String name = "", role = "", phone = "", profilePicUrl = "";
  bool isLoadingStats = true;
  bool isUploading = false;
  bool _showInvestment = false;

  double totalDeposit = 0.0;
  double totalProfit = 0.0;
  double totalInvestment = 0.0;
  int activeProjects = 0;

  @override
  void initState() { super.initState(); _loadData(); }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('userName') ?? "User";
      role = prefs.getString('userRole') ?? "Member";
      phone = prefs.getString('userPhone') ?? "";
      profilePicUrl = prefs.getString('userPic') ?? "";
    });
    _fetchStats();
  }

  void _fetchStats() async {
    var txRes = await ApiService.getTransactions();
    if (txRes is List) {
      double tempDeposit = 0.0;
      for (var tx in txRes) {
        if (tx['MemberName'].toString().trim() == name.trim()) {
          double amount = double.tryParse(tx['Amount'].toString()) ?? 0.0;
          if (tx['Type'] == 'জমা' && tx['Status'] == 'Paid') {
            tempDeposit += amount;
          }
        }
      }
      setState(() => totalDeposit = tempDeposit);
    }

    var invRes = await ApiService.getInvestments();
    if (invRes is List) {
      double tempProfit = 0.0;
      double tempInv = 0.0;
      int tempActive = 0;
      for (var inv in invRes) {
        double profit = double.tryParse(inv['ProfitAmount'].toString()) ?? 0.0;
        double amount = double.tryParse(inv['InvestAmount'].toString()) ?? 0.0;
        tempProfit += profit;
        if (inv['Status'] == 'সক্রিয়') { tempActive++; tempInv += amount; }
      }
      setState(() { totalProfit = tempProfit; totalInvestment = tempInv; activeProjects = tempActive; isLoadingStats = false; });
    } else { setState(() => isLoadingStats = false); }
  }

  // 🔥 প্রোফাইল ছবি আপলোড
  Future<void> _pickAndUploadProfilePic() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 10, 
      maxWidth: 200,
      maxHeight: 200,
    );
    
    if (image != null) {
      setState(() => isUploading = true);
      File file = File(image.path);
      List<int> imageBytes = await file.readAsBytes();
      String base64String = base64Encode(imageBytes);
      String base64Data = "data:image/jpeg;base64,$base64String";

      var res = await ApiService.updateProfilePic(phone: phone, base64: base64Data);
      
      if (res['status'] == "success" || res['message'] == "Updated" || res['message'].contains("302")) {
        var members = await ApiService.getAllMembers();
        if (members is List) {
          String cleanPhone = phone.startsWith('0') ? phone.substring(1) : phone;
          var myData = members.firstWhere((m) {
            String mPhone = m['Phone'].toString();
            if(mPhone.startsWith('0')) mPhone = mPhone.substring(1);
            return mPhone == cleanPhone;
          }, orElse: () => null);

          if (myData != null && myData['ProfilePicUrl'] != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('userPic', myData['ProfilePicUrl']);
            setState(() => profilePicUrl = myData['ProfilePicUrl']);
          }
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("প্রোফাইল ছবি আপডেট হয়েছে!"), backgroundColor: Colors.green));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ছবি আপলোডে সমস্যা হয়েছে!"), backgroundColor: Colors.red));
      }
      setState(() => isUploading = false);
    }
  }

  // 🔥 ফুল স্ক্রিন ছবি দেখার ডায়ালগ
  void _showFullImage() {
    if (profilePicUrl.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Image.network(
              profilePicUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 50)),
            ),
          ),
        ),
      ),
    );
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
  }

  // 🔥 পিন পরিবর্তনের লজিক (৪-১০ ডিজিট এবং একই অঙ্ক ৪ বার নয়)
  void _showPinChangeDialog() {
    TextEditingController oldPinController = TextEditingController();
    TextEditingController newPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("পিন পরিবর্তন করুন"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldPinController, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "পুরোনো পিন")),
            const SizedBox(height: 10),
            TextField(controller: newPinController, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "নতুন পিন (৪-১০ ডিজিট)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("বাতিল")),
          ElevatedButton(
            onPressed: () async {
              String newPin = newPinController.text.trim();
              
              // ভ্যালিডেশন
              if (newPin.length < 4 || newPin.length > 10) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("পিন ৪ থেকে ১০ ডিজিটের হতে হবে!"), backgroundColor: Colors.orange));
                return;
              }
              // একই সংখ্যা ৪ বার চেক (যেমন: 1111, 2222)
              if (RegExp(r'^(\d)\1{3,9}$').hasMatch(newPin)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("একই সংখ্যা বারবার ব্যবহার করা যাবে না!"), backgroundColor: Colors.red));
                return;
              }

              if (oldPinController.text.isNotEmpty) {
                var res = await ApiService.updatePin(phone: phone, newPin: newPin);
                if (res['status'] == 'success' || res['message'] == "Updated" || res['message'].contains("302")) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("পিন সফলভাবে আপডেট হয়েছে!"), backgroundColor: Colors.green));
                }
              }
            },
            child: const Text("সেভ"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(color: Color(0xFF00796B), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickAndUploadProfilePic,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 35, 
                          backgroundColor: Colors.white, 
                          // 🔥 এখানে backgroundImage সরাসরি দেওয়া হয়েছে
                          backgroundImage: profilePicUrl.isNotEmpty ? NetworkImage(profilePicUrl) : null,
                          child: profilePicUrl.isEmpty ? const Icon(Icons.person, size: 40, color: Color(0xFF00796B)) : null
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                            child: isUploading 
                              ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.camera_alt, size: 15, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔥 নামের পাশে ছবিতে ক্লিক করলে ফুল স্ক্রিন দেখার আইকন
                        GestureDetector(
                          onTap: _showFullImage,
                          child: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        const SizedBox(height: 5),
                        Text(role == 'Admin' ? "অ্যাডমিন" : "সাধারণ সদস্য", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            
            // ... (বাকি স্ট্যাটস কার্ড এবং মেনু আগের মতোই থাকবে)
            Transform.translate(
              offset: const Offset(0, -15),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: isLoadingStats ? const Center(child: CircularProgressIndicator()) : Column(
                  children: [
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: const Color(0xFF00796B), borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("মোট বিনিয়োগ", style: TextStyle(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 5),
                              Text(_showInvestment ? "৳ ${totalInvestment.toStringAsFixed(0)}" : "৳ ******", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          IconButton(icon: Icon(_showInvestment ? Icons.visibility : Icons.visibility_off, color: Colors.white), onPressed: () => setState(() => _showInvestment = !_showInvestment))
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard("মোট লাভ", "৳ ${totalProfit.toStringAsFixed(0)}", Icons.trending_up, Colors.green, isDark)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildStatCard("মোট জমা", "৳ ${totalDeposit.toStringAsFixed(0)}", Icons.account_balance_wallet, Colors.teal, isDark)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildStatCard("সক্রিয় প্রকল্প", "$activeProjects টি", Icons.layers, Colors.orange, isDark)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _buildMenuTile(Icons.notifications_none, "নোটিফিকেশন সেটিংস", () { Navigator.push(context, MaterialPageRoute(builder: (c) => const AppSettingsScreen())); }),
            _buildMenuTile(Icons.security, "সুরক্ষা ও গোপনীয়তা (পিন)", _showPinChangeDialog),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode, color: Colors.blueGrey),
              title: const Text("ডার্ক মোড", style: TextStyle(fontWeight: FontWeight.w500)),
              value: themeNotifier.value == ThemeMode.dark,
              activeColor: const Color(0xFF00796B),
              onChanged: (val) async {
                themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isDarkMode', val);
              },
            ),
            _buildMenuTile(Icons.info_outline, "অ্যাপ সম্পর্কে", () {
              showAboutDialog(context: context, applicationName: "বিনিয়োগ উদ্যোক্তা", applicationVersion: "1.0.0", children: [const Text("সমিতির সব হিসাব এক অ্যাপে।")]);
            }),
            const SizedBox(height: 20),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text("লগআউট", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), onTap: _logout),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24), const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10)), const SizedBox(height: 4),
          FittedBox(child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon, color: Colors.blueGrey), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)), trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), onTap: onTap);
  }
}