import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';

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
      home: const LoginScreen(),
    );
  }
}