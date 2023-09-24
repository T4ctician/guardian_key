import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guardian_key/src/features/authentication/screens/homepage.dart';
import 'package:guardian_key/src/features/authentication/screens/login.dart';
import 'package:guardian_key/src/features/authentication/screens/welcome_screen.dart'; // Import the homepage.dart file
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Guardian Key',
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(), // Use the HomePage widget from homepage.dart
    );
  }
}
