import 'package:flutter/material.dart';

class LogoBlock extends StatelessWidget {
  const LogoBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/isylsi_logo.png',
          width: 120,
          height: 120,
          color: const Color(0xFFD4AF37),
        ),
        const SizedBox(height: 12),
        const Text(
          'AI Powered Quizzes For CBSE Classes 6 – 10',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.white70,
            height: 1.5,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}