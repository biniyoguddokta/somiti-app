import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ConstitutionScreen extends StatefulWidget {
  const ConstitutionScreen({super.key});

  @override
  State<ConstitutionScreen> createState() => _ConstitutionScreenState();
}

class _ConstitutionScreenState extends State<ConstitutionScreen> {
  List<dynamic> pages = [];
  bool isLoading = true;
  String userRole = "Member";

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchData();
  }

  void _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => userRole = prefs.getString('userRole') ?? "Member");
  }

  void _fetchData() async {
    setState(() => isLoading = true);
    var res = await ApiService.getConstitution();
    if (res is List) {
      setState(() { pages = res; isLoading = false; });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _showAddDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("নতুন ধারা যোগ করুন"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "ধারার হেডলাইন")),
              const SizedBox(height: 10),
              TextField(controller: contentController, maxLines: 4, decoration: const InputDecoration(labelText: "ধারার বিস্তারিত নোট")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("বাতিল")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B)),
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                setState(() => isLoading = true);
                await ApiService.addConstitution(title: titleController.text, content: contentController.text);
                Navigator.pop(context);
                _fetchData();
              }
            },
            child: const Text("সেভ", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("গঠনতন্ত্র"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pages.isEmpty
              ? const Center(child: Text("কোনো তথ্য পাওয়া যায়নি!"))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    var page = pages[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)),
                      child: ExpansionTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.menu_book, color: Color(0xFF00796B)),
                        ),
                        title: Text(page['Title'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(page['Content'].toString(), style: const TextStyle(height: 1.5, fontSize: 15)),
                          )
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: userRole == 'Admin' 
        ? FloatingActionButton(
            backgroundColor: const Color(0xFF00796B),
            onPressed: _showAddDialog,
            child: const Icon(Icons.add, color: Colors.white),
          )
        : null,
    );
  }
}