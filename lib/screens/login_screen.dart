import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
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
  bool _isPasswordVisible = false;

  void _login() async {
    String phone = _phoneController.text.trim();
    String pin = _pinController.text.trim();

    if (phone.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ফোন নম্বর এবং পিন দিন"), backgroundColor: Colors.orange),
      );
      return;
    }

    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    setState(() { _isLoading = true; });

    try {
      var response = await ApiService.getAllMembers();

      if (response is Map && response.containsKey('error')) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error']), backgroundColor: Colors.red),
        );
        return;
      }

      List members = response;
      bool isAuthenticated = false;
      String userRole = "Member";
      String userName = "User";

      for (var member in members) {
        String dbPhone = member['Phone'].toString().trim();
        String dbPin = member['PIN'].toString().trim();
        if (dbPhone.endsWith('.0')) dbPhone = dbPhone.replaceAll('.0', '');
        if (dbPin.endsWith('.0')) dbPin = dbPin.replaceAll('.0', '');
        if (dbPhone.startsWith('0')) dbPhone = dbPhone.substring(1);

        if (dbPhone == phone && dbPin == pin) {
          isAuthenticated = true;
          userRole = member['Role'].toString();
          userName = member['Name'].toString();
          break;
        }
      }

      if (isAuthenticated) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userPhone', phone);
        await prefs.setString('userRole', userRole);
        await prefs.setString('userName', userName);

        if (!mounted) return;
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ভুল ফোন নম্বর বা পিন!"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("সমস্যা হয়েছে: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔥 ২ নং স্ক্রিনশটের মতো ব্যাকগ্রাউন্ড ডিজাইন
          Container(
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF004D40), Color(0xFF00796B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
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
                  const SizedBox(height: 30),
                  
                  // 🔥 আপনার আপলোড করা লগইন ব্যানার
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                    ),
                    child: Image.asset(
                      'assets/login_banner.png', // আপনার আপলোড করা ব্যানারের নাম
                      height: 120,
                      fit: BoxFit.contain,
                      // 🔥 যদি ছবি না থাকে, তবে পুরোনো ডামি ছবি দেখাবে
                      errorBuilder: (c, e, s) => Image.network('https://via.placeholder.com/300x100?text=Your+Banner+Here', height: 100),
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  const Text(
                    "স্বাগতম",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "বিনিয়োগ উদ্যোক্তার সব হিসাব — এক অ্যাপে",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),
                  
                  // লগইন কার্ড
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ফোন নম্বর ইনপুট
                        const Text("ফোন নম্বর", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00796B))),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: const Icon(Icons.phone, color: Color(0xFF00796B)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // পিন ইনপুট
                        const Text("পিন", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00796B))),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _pinController,
                          obscureText: !_isPasswordVisible,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: const Icon(Icons.lock, color: Color(0xFF00796B)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
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
                  
                  const SizedBox(height: 20),
                  
                  // নিচের ফিচার আইকন
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFeatureIcon(Icons.security, "নিরাপদ"),
                      _buildFeatureIcon(Icons.trending_up, "লাভজনক"),
                      _buildFeatureIcon(Icons.handshake, "বিশ্বস্ত সহযোগী"),
                      _buildFeatureIcon(Icons.spa, "উন্নয়নের পথে"),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: const Color(0xFFFFD54F), size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}