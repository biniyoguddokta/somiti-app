import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ConstitutionScreen extends StatefulWidget {
  const ConstitutionScreen({super.key});

  @override
  State<ConstitutionScreen> createState() => _ConstitutionScreenState();
}

class _ConstitutionScreenState extends State<ConstitutionScreen> {
  List<dynamic> pages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
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
    );
  }
}