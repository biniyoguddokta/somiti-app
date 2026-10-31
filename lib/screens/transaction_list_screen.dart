
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  final String type;

  // ব্যবহারকারীর Role
  final String? userRole;

  const TransactionListScreen({
    super.key,
    required this.type,
    this.userRole,
  });

  @override
  State<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState
    extends State<TransactionListScreen> {
  List<dynamic> transactions = [];

  bool isLoading = true;

  String currentUserRole = 'Member';

  // শুধু Admin নতুন হিসাব যোগ করতে পারবে
  bool get isAdmin =>
      currentUserRole.trim().toLowerCase() == 'admin';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  // ব্যবহারকারীর Role সংগ্রহ
  Future<void> _loadUserRole() async {
    if (widget.userRole != null &&
        widget.userRole!.trim().isNotEmpty) {
      currentUserRole = widget.userRole!;
    } else {
      SharedPreferences prefs =
          await SharedPreferences.getInstance();

      currentUserRole =
          prefs.getString('userRole') ?? 'Member';
    }

    if (!mounted) return;

    setState(() {});

    _fetchData();
  }

  // লেনদেন লোড
  Future<void> _fetchData() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      var res = await ApiService.getTransactions();

      if (!mounted) return;

      if (res is List) {
        setState(() {
          // শুধু নির্দিষ্ট ধরনের লেনদেন দেখাবে
          transactions = res
              .where(
                (tx) =>
                    tx['Type'].toString().trim() ==
                    widget.type.trim(),
              )
              .toList()
              .reversed
              .toList();

          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      debugPrint("Transaction Loading Error: $e");
    }
  }

  // নতুন লেনদেন যোগ
  Future<void> _addTransaction() async {
    // অতিরিক্ত Permission Check
    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("আপনার নতুন হিসাব যোগ করার অনুমতি নেই।"),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => AddTransactionScreen(
          type: widget.type,
        ),
      ),
    );

    if (mounted) {
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: Text("${widget.type} এর তালিকা"),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
            tooltip: "রিফ্রেশ",
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : transactions.isEmpty
                ? ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Center(
                        child: Text(
                          "কোনো লেনদেন পাওয়া যায়নি!",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(15),
                    itemCount: transactions.length,

                    itemBuilder: (context, index) {
                      var tx = transactions[index];

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),

                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                const Color(0xFF00796B)
                                    .withOpacity(0.1),
                            child: const Icon(
                              Icons.money,
                              color: Color(0xFF00796B),
                            ),
                          ),

                          title: Text(
                            tx['MemberName']?.toString() ??
                                'অজানা সদস্য',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Text(
                            "${tx['Note'] ?? ''} | "
                            "${tx['Date']?.toString().split(' ')[0] ?? ''}",
                          ),

                          trailing: Text(
                            "৳ ${tx['Amount'] ?? '0'}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF00796B),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),

      // শুধু Admin প্লাস বাটন দেখতে পাবে
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor:
                  const Color(0xFF00796B),
              onPressed: _addTransaction,
              tooltip: "নতুন হিসাব যোগ করুন",
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}
