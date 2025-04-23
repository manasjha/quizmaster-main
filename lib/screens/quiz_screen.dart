import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
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
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  int? selectedOptionIndex;

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[currentIndex];
    final options = currentQuestion['options'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.quizTitle,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Q${currentIndex + 1}. ${currentQuestion['question_text'] ?? ''}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 24),
            ...List.generate(options.length, (index) {
              final isSelected = index == selectedOptionIndex;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.pink : Colors.grey[900],
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () {
                    setState(() => selectedOptionIndex = index);
                  },
                  child: Text(
                    options[index].toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${currentIndex + 1} of ${widget.questions.length}',
                  style: const TextStyle(color: Colors.white70),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (currentIndex < widget.questions.length - 1) {
                      setState(() {
                        currentIndex++;
                        selectedOptionIndex = null;
                      });
                    } else {
                      // TODO: Handle end of quiz
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE62E53),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    currentIndex == widget.questions.length - 1 ? "Finish" : "Next",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}