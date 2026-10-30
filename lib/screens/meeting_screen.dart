import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  List<dynamic> meetings = [];
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
    var res = await ApiService.getMeetings();
    if (res is List) {
      setState(() { meetings = res.reversed.toList(); isLoading = false; });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _showAddDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();
    TextEditingController dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("নতুন সভা যোগ করুন"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "সভার হেডলাইন / বিষয়")),
              const SizedBox(height: 10),
              TextField(controller: descController, maxLines: 3, decoration: const InputDecoration(labelText: "নোট / বিবরণ")),
              const SizedBox(height: 10),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: "তারিখ"),
                onTap: () async {
                  DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                  if (picked != null) dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                },
              ),
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
                await ApiService.addMeeting(date: dateController.text, title: titleController.text, description: descController.text);
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
      appBar: AppBar(title: const Text("সভা সমূহ"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : meetings.isEmpty
              ? const Center(child: Text("কোনো সভা পাওয়া যায়নি!"))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: meetings.length,
                  itemBuilder: (context, index) {
                    var m = meetings[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ExpansionTile(
                        leading: const Icon(Icons.calendar_month, color: Color(0xFF00796B)),
                        title: Text(m['Title'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("তারিখ: ${m['Date']}"),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(m['Description'].toString(), style: const TextStyle(height: 1.5)),
                          )
                        ],
                      ),
                    );
                  },
                ),
      // 🔥 শুধু অ্যাডমিন + বাটন দেখবে
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