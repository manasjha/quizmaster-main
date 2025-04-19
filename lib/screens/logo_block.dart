import 'package:flutter/material.dart';

class LogoBlock extends StatelessWidget {
  const LogoBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logo/isylsi_logo.png',
          width: 240,
          height: 120,
        ),
        const SizedBox(height: 0),
        const Text(
          'AI Powered Quizzes For CBSE Classes 6 – 10',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            color: Colors.white70,
            height: 1.5,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}