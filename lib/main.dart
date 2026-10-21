import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Somiti App',
      theme: ThemeData(
        primaryColor: const Color(0xFF00796B),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        textTheme: GoogleFonts.hindSiliguriTextTheme(Theme.of(context).textTheme),
      ),
      home: const SplashScreen(), // প্রথমে স্প্ল্যাশ স্ক্রিন দেখাবে
    );
  }
}

// স্প্ল্যাশ স্ক্রিন (লগইন চেক করার জন্য)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    try {
      // মেমোরি থেকে ডেটা পড়ার চেষ্টা করবে
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      // ২ সেকেন্ড অপেক্ষা করবে (যাতে স্প্ল্যাশ স্ক্রিন সুন্দর দেখায়)
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      
      if (isLoggedIn) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    } catch (e) {
      // যদি কোনো কারণবশত এরর হয়, তবে আটকে না থেকে সরাসরি লগইন পেজে যাবে
      print("Error reading login status: $e");
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF00796B)),
      ),
    );
  }
}