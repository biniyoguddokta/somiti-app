// Final Build
 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart'; // নতুন লগইন স্ক্রিন ইমপোর্ট করা হলো

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
        primaryColor: const Color(0xFF00796B), // নতুন কালার
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        textTheme: GoogleFonts.hindSiliguriTextTheme(Theme.of(context).textTheme), // বাংলা ফন্ট
      ),
      home: const LoginScreen(), // এখানে ড্যাশবোর্ডের বদলে লগইন স্ক্রিন বসানো হলো
    );
  }
}