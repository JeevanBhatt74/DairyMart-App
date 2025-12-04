// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure this is imported
import 'screens/splash/splash_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner
      title: 'DairyMart',
      
      // --- ADD THEME DATA HERE ---
      theme: ThemeData(
        // 1. Set the background color to white
        scaffoldBackgroundColor: Colors.white,

        // 2. Define the Color Scheme using your Logo's Blue
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF29ABE2), // DairyMart Blue
          primary: const Color(0xFF29ABE2),   // Explicitly set primary
          secondary: const Color(0xFFE6E7E8), // Light Gray from Logo
        ),

        // 3. Set the global font to Poppins
        fontFamily: GoogleFonts.poppins().fontFamily,
        
        // 4. Enable Material 3 for modern buttons and inputs
        useMaterial3: true,
      ),
      // ---------------------------

      home: const SplashScreen(),
    );
  }
}