import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Onboarding3 extends StatelessWidget {
  const Onboarding3({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF29ABE2);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              // FIXED: Replaced withOpacity with withValues to fix deprecation warning
              color: primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_outlined, size: 100, color: primaryBlue),
          ),
          const SizedBox(height: 50),
          Text(
            "Quality Assurance",
            style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: primaryBlue),
          ),
          const SizedBox(height: 20),
          Text(
            "Every product is tested for purity and quality. We ensure only the best reaches your family.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600], height: 1.5),
          ),
        ],
      ),
    );
  }
}