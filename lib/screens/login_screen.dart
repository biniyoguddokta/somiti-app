import 'package:flutter/material.dart';
import '../services/api_service.dart'; // API সার্ভিস ইমপোর্ট
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;

  // লগইন ফাংশন
  void _login() async {
    String phone = _phoneController.text.trim();
    String pin = _pinController.text.trim();

    // ১. চেক করা হচ্ছে ইনপুট খালি কি না
    if (phone.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ফোন নম্বর এবং পিন দিন"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() { _isLoading = true; });

    // ২. গুগল শিট থেকে ডেটা চেক করা
    var members = await ApiService.getAllMembers();
    bool isAuthenticated = false;

    for (var member in members) {
      // গুগল শিট থেকে আসা ডেটাকে টেক্সটে রূপান্তর এবং বাড়তি স্পেস বাদ দেওয়া
      String dbPhone = member['Phone'].toString().trim();
      String dbPin = member['PIN'].toString().trim();

      // যদি ডেটার শেষে .0 থাকে (যেমন 1234.0), তবে সেটি কেটে ফেলা হবে
      if (dbPhone.endsWith('.0')) dbPhone = dbPhone.replaceAll('.0', '');
      if (dbPin.endsWith('.0')) dbPin = dbPin.replaceAll('.0', '');

      // ৩. ফোন নম্বর এবং পিন মিলিয়ে দেখা হচ্ছে
      if (dbPhone == phone && dbPin == pin) {
        isAuthenticated = true;
        break;
      }
    }

    setState(() { _isLoading = false; });

    // ৪. লগইন সফল বা ব্যর্থ হলে যা হবে
    if (isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ভুল ফোন নম্বর বা পিন!"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // উপরের সবুজ অংশ
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: const BoxDecoration(
              color: Color(0xFF00796B),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // ব্যানার ইমেজ
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.network(
                      'https://via.placeholder.com/300x100?text=Your+Banner+Here',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "স্বাগতম",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "বিনিয়োগ উদ্যোক্তার সব হিসাব — এক অ্যাপে",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),
                  
                  // নিচের সাদা কার্ড অংশ
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ফোন নম্বর ইনপুট
                        const Text("ফোন নম্বর", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // পিন ইনপুট
                        const Text("পিন", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _pinController,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: const Icon(Icons.password),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // লগইন বাটন
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00796B),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text("পিন দিয়ে ঢুকুন  ", style: TextStyle(fontSize: 18, color: Colors.white)),
                                    Icon(Icons.arrow_forward, color: Colors.white),
                                  ],
                                ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}