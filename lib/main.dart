import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance App',
      theme: ThemeData(primarySwatch: Colors.green, scaffoldBackgroundColor: Color(0xFFF5F7FA)),
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    // এখানে আপনার Apps Script Web App URL দিন
    final url = Uri.parse('https://script.google.com/macros/s/AKfycbzu3cVu5OLUujiqdaFz6siX7AEk_s7jjrxjbhj641aYhAnNraK6JenS11ZIks1eOn0_/exec'); 
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          data = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("হোম", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading 
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCard("সদস্য সংখ্যা", data.isNotEmpty ? "${data.length} জন" : "০ জন", Colors.blue),
                  SizedBox(height: 16),
                  Text("মডিউল ও ফিচার", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      _buildIconButton(Icons.group_add, "সদস্য যোগ", Colors.green),
                      _buildIconButton(Icons.group, "সদস্য", Colors.blue),
                      _buildIconButton(Icons.account_balance, "ব্যাংক", Colors.purple),
                      _buildIconButton(Icons.savings, "DPS", Colors.teal),
                      _buildIconButton(Icons.account_balance_wallet, "FDR", Colors.indigo),
                      _buildIconButton(Icons.receipt, "লোন", Colors.orange),
                    ],
                  )
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "হোম"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "সদস্য"),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: "কালেকশন"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "রিপোর্ট"),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "আরও"),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(Icons.people, color: color)),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey)),
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}