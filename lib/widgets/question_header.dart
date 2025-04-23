import 'package:flutter/material.dart';

class QuestionHeader extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final String topic;
  final double progress; // value from 1.0 to 0.0

  const QuestionHeader({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.topic,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              Text(
                'Q$currentQuestion of $totalQuestions',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                'Topic: $topic',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white24,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE62E53)),
          minHeight: 3,
        ),
      ],
    );
  }
}