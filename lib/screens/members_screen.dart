import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'member_profile_screen.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  List<dynamic> members = [];
  List<dynamic> filteredMembers = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  void _fetchMembers() async {
    setState(() => isLoading = true);
    var response = await ApiService.getAllMembers();
    
    if (response is Map && response.containsKey('error')) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error']), backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (response is List) {
      setState(() {
        members = response;
        filteredMembers = response;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _filterMembers(String query) {
    setState(() {
      filteredMembers = members.where((member) {
        String name = member['Name'].toString().toLowerCase();
        String phone = member['Phone'].toString();
        return name.contains(query.toLowerCase()) || phone.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // 🔥 কালো স্ক্রিন ফিক্স
      appBar: AppBar(
        title: const Text("সদস্য তালিকা"),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchMembers)
        ],
      ),
      body: Column(
        children: [
          // সার্চ বার
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMembers,
              decoration: InputDecoration(
                hintText: "সদস্য খুঁজুন...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),

          // সদস্য লিস্ট
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredMembers.isEmpty
                    ? const Center(child: Text("কোনো সদস্য পাওয়া যায়নি!"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: filteredMembers.length,
                        itemBuilder: (context, index) {
                          var member = filteredMembers[index];
                          bool isAdmin = member['Role'].toString() == 'Admin';
                          String name = member['Name'].toString();
                          String designation = member['Designation']?.toString() ?? (isAdmin ? "প্রতিষ্ঠাতা / অ্যাডমিন" : "সদস্য");

                          return Card(
                            color: Colors.white, // 🔥 কার্ডের কালার ফিক্স
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: isAdmin ? const Color(0xFF00796B) : Colors.blue,
                                child: Text(name.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Text(designation, style: TextStyle(color: isAdmin ? const Color(0xFF00796B) : Colors.grey, fontWeight: isAdmin ? FontWeight.bold : FontWeight.normal)),
                              trailing: isAdmin ? const Icon(Icons.workspace_premium, color: Colors.amber) : const Icon(Icons.circle, color: Colors.green, size: 12),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (c) => MemberProfileScreen(member: member)));
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}