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
  double myProfitShare = 0.0; 
  double myIncome = 0.0; 
  double totalInvestment = 0.0;
  int activeProjects = 0;
  int totalMembers = 0; 
  
  List<dynamic> myTransactions = [];
  List<dynamic> myInvestments = [];

  @override
  void initState() { super.initState(); _loadData(); }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('userName') ?? "User";
      role = prefs.getString('userRole') ?? "Member";
      phone = prefs.getString('userPhone') ?? "";
      
      // ক্যাশ এড়ানোর জন্য টাইম স্ট্যাম্প
      String savedPic = prefs.getString('userPic') ?? "";
      if (savedPic.isNotEmpty) {
        profilePicUrl = "$savedPic&t=${DateTime.now().millisecondsSinceEpoch}";
      } else {
        profilePicUrl = "";
      }
    });
    _fetchStats();
  }

  void _fetchStats() async {
    setState(() => isLoadingStats = true);
    
    var membersRes = await ApiService.getAllMembers();
    if (membersRes is List) {
      totalMembers = membersRes.length;
    }

    var txRes = await ApiService.getTransactions();
    if (txRes is List) {
      List<dynamic> tempMyTx = txRes.where((tx) => tx['MemberName'].toString().trim() == name.trim()).toList();
      double tempDeposit = 0.0;
      double tempIncome = 0.0;
      
      for (var tx in tempMyTx) {
        double amount = double.tryParse(tx['Amount'].toString()) ?? 0.0;
        if (tx['Status'] == 'Paid') {
          if (tx['Type'] == 'জমা' || tx['Type'] == 'বিলম্ব ফী') tempDeposit += amount;
          if (tx['Type'] == 'আয়') tempIncome += amount;
        }
      }
      setState(() {
        myTransactions = tempMyTx.reversed.toList();
        totalDeposit = tempDeposit;
        myIncome = tempIncome;
      });
    }

    var invRes = await ApiService.getInvestments();
    if (invRes is List) {
      double tempTotalProjectProfit = 0.0;
      double tempInv = 0.0;
      int tempActive = 0;
      List<dynamic> tempMyInv = [];
      
      for (var inv in invRes) {
        double profit = double.tryParse(inv['ProfitAmount'].toString()) ?? 0.0;
        double amount = double.tryParse(inv['InvestAmount'].toString()) ?? 0.0;
        
        tempTotalProjectProfit += profit; 
        
        if (inv['Status'] == 'সক্রিয়') { 
          tempActive++; 
          tempInv += amount; 
          tempMyInv.add(inv);
        }
      }

      double perMemberProfit = 0.0;
      if (totalMembers > 0) {
        perMemberProfit = tempTotalProjectProfit / totalMembers;
      }

      setState(() { 
        totalInvestment = tempInv; 
        activeProjects = tempActive; 
        myInvestments = tempMyInv;
        myProfitShare = perMemberProfit; 
        isLoadingStats = false; 
      });
    } else { setState(() => isLoadingStats = false); }
  }

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
            String newPicUrl = "${myData['ProfilePicUrl']}&t=${DateTime.now().millisecondsSinceEpoch}";
            await prefs.setString('userPic', newPicUrl);
            setState(() => profilePicUrl = newPicUrl);
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

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
  }

  // 🔥 পিন পরিবর্তনের ফাংশন (পুরোনো পিন চেক ও কনফার্ম পিনসহ)
  void _showPinChangeDialog() {
    TextEditingController oldPinController = TextEditingController();
    TextEditingController newPinController = TextEditingController();
    TextEditingController confirmPinController = TextEditingController();

    String currentDbPin = "";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("পিন পরিবর্তন করুন"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: oldPinController, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "পুরোনো পিন")),
                  const SizedBox(height: 10),
                  TextField(controller: newPinController, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "নতুন পিন (৪-১০ ডিজিট)")),
                  const SizedBox(height: 10),
                  TextField(controller: confirmPinController, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "নতুন পিন কনফার্ম করুন")),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("বাতিল")),
              ElevatedButton(
                onPressed: () async {
                  String oldPin = oldPinController.text.trim();
                  String newPin = newPinController.text.trim();
                  String confirmPin = confirmPinController.text.trim();

                  if (newPin.length < 4 || newPin.length > 10) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("নতুন পিন ৪ থেকে ১০ ডিজিটের হতে হবে!"), backgroundColor: Colors.orange));
                    return;
                  }
                  if (RegExp(r'^(\d)\1{3,9}$').hasMatch(newPin)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("একই সংখ্যা বারবার ব্যবহার করা যাবে না!"), backgroundColor: Colors.red));
                    return;
                  }
                  if (newPin != confirmPin) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("নতুন পিন এবং কনফার্ম পিন মিলছে না!"), backgroundColor: Colors.red));
                    return;
                  }

                  setDialogState(() {});
                  var members = await ApiService.getAllMembers();
                  if (members is List) {
                    String cleanPhone = phone.startsWith('0') ? phone.substring(1) : phone;
                    var myData = members.firstWhere((m) {
                      String mPhone = m['Phone'].toString();
                      if(mPhone.startsWith('0')) mPhone = mPhone.substring(1);
                      return mPhone == cleanPhone;
                    }, orElse: () => null);

                    if (myData != null) {
                      currentDbPin = myData['PIN'].toString();
                    }
                  }

                  if (oldPin != currentDbPin) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("পুরোনো পিনটি সঠিক নয়!"), backgroundColor: Colors.red));
                    return;
                  }

                  var res = await ApiService.updatePin(phone: phone, newPin: newPin);
                  if (res['status'] == 'success' || res['message'] == "Updated" || res['message'].contains("302")) {
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("পিন সফলভাবে আপডেট হয়েছে!"), backgroundColor: Colors.green));
                  } else {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("পিন আপডেটে সমস্যা হয়েছে!"), backgroundColor: Colors.red));
                  }
                },
                child: const Text("সেভ"),
              )
            ],
          );
        }
      ),
    );
  }

  void _showHistoryDialog(String title, List<dynamic> data, bool isInvestment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            Expanded(
              child: data.isEmpty 
                ? const Center(child: Text("কোনো ডেটা নেই"))
                : ListView.builder(
                    controller: scrollController,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      var item = data[index];
                      if (isInvestment) {
                        return ListTile(
                          leading: const Icon(Icons.menu_book, color: Colors.purple),
                          title: Text(item['ProjectName'].toString()),
                          subtitle: Text("৳ ${item['InvestAmount']} | লাভ: ৳ ${item['ProfitAmount']}"),
                          trailing: Text(item['Status'].toString()),
                        );
                      } else {
                        return ListTile(
                          leading: Icon(item['Type'] == 'জমা' ? Icons.arrow_downward : Icons.arrow_upward, color: item['Type'] == 'জমা' ? Colors.green : Colors.red),
                          title: Text(item['Type'].toString()),
                          subtitle: Text(item['Note'].toString()),
                          trailing: Text("৳ ${item['Amount']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        );
                      }
                    },
                  ),
            )
          ],
        ),
      ),
    );
  }

  void _showFullImage() {
    if (profilePicUrl.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 1,
            maxScale: 5,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black87,
              child: Image.network(
                profilePicUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Colors.white, size: 60),
                      SizedBox(height: 10),
                      Text("ছবিটি লোড করা যাচ্ছে না", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    double displayTotalProfit = myProfitShare + myIncome;

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
                    onTap: profilePicUrl.isNotEmpty ? _showFullImage : _pickAndUploadProfilePic,
                    child: Stack(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: ClipOval(
                            child: profilePicUrl.isNotEmpty 
                              ? Image.network(
                                  profilePicUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.person, size: 40, color: Color(0xFF00796B));
                                  },
                                )
                              : const Icon(Icons.person, size: 40, color: Color(0xFF00796B)),
                          ),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: GestureDetector(
                            onTap: _pickAndUploadProfilePic,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                              child: isUploading 
                                ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.camera_alt, size: 15, color: Colors.white),
                            ),
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
                        Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 5),
                        Text(role == 'Admin' ? "অ্যাডমিন" : "সাধারণ সদস্য", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            
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
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showHistoryDialog("আমার লাভের হিস্ট্রি", myTransactions.where((tx) => tx['Type'] == 'আয়').toList(), false),
                            child: _buildStatCard("মোট লাভ", "৳ ${displayTotalProfit.toStringAsFixed(0)}", Icons.trending_up, Colors.green, isDark)
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showHistoryDialog("আমার জমার হিস্ট্রি", myTransactions.where((tx) => tx['Type'] == 'জমা' || tx['Type'] == 'বিলম্ব ফী').toList(), false),
                            child: _buildStatCard("মোট জমা", "৳ ${totalDeposit.toStringAsFixed(0)}", Icons.account_balance_wallet, Colors.teal, isDark)
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showHistoryDialog("আমার বিনিয়োগ", myInvestments, true),
                            child: _buildStatCard("সক্রিয় প্রকল্প", "$activeProjects টি", Icons.layers, Colors.orange, isDark)
                          ),
                        ),
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