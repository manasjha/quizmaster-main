import 'package:flutter/material.dart';

class QuizScreen extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final String quizTitle;
  final bool isDiagnostic;

  const QuizScreen({
    super.key,
    required this.questions,
    required this.quizTitle,
    required this.isDiagnostic,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          quizTitle,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];
          return ListTile(
            title: Text(
              q['question_text'] ?? 'No text',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Format: ${q['format']}',
              style: const TextStyle(color: Colors.white54),
            )
          );
        },
      ),
    );
  }
}
