import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CommitteeScreen extends StatefulWidget {
  final String userRole;
  const CommitteeScreen({super.key, required this.userRole});

  @override
  State<CommitteeScreen> createState() => _CommitteeScreenState();
}

class _CommitteeScreenState extends State<CommitteeScreen> {
  List<dynamic> members = [];
  bool isLoading = true;

  @override
  void initState() { super.initState(); _fetchData(); }

  void _fetchData() async {
    setState(() => isLoading = true);
    var res = await ApiService.getAllMembers();
    if (res is List) {
      setState(() { members = res; isLoading = false; });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _updateDesignation(String phone, String currentDesignation) async {
    TextEditingController _controller = TextEditingController(text: currentDesignation);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("পদবি পরিবর্তন করুন"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: "যেমন: সভাপতি, ক্যাশিয়ার"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("বাতিল")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isLoading = true);
              await ApiService.updateDesignation(phone: phone, designation: _controller.text.trim());
              _fetchData();
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
      appBar: AppBar(title: const Text("কমিটি ও দায়িত্ব"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: members.length,
              itemBuilder: (context, index) {
                var member = members[index];
                String name = member['Name'].toString();
                String designation = member['Designation']?.toString() ?? "সদস্য";

                return Card(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.blue, child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white))),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    // 🔥 পদবি ধূসর কালারে ছোট করে দেখানো হলো
                    subtitle: Text(designation, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    trailing: widget.userRole == 'Admin' 
                      ? IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _updateDesignation(member['Phone'].toString(), designation),
                        )
                      : null,
                  ),
                );
              },
            ),
    );
  }
}