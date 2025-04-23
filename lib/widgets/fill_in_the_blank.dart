import 'package:flutter/material.dart';

class FillInTheBlankWidget extends StatefulWidget {
  final String correctAnswer;
  final bool isAnswered;
  final Function(bool isCorrect, String userAnswer) onSubmit;

  const FillInTheBlankWidget({
    super.key,
    required this.correctAnswer,
    required this.isAnswered,
    required this.onSubmit,
  });

  @override
  State<FillInTheBlankWidget> createState() => _FillInTheBlankWidgetState();
}

class _FillInTheBlankWidgetState extends State<FillInTheBlankWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Type your answer below',
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          enabled: !widget.isAnswered,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Your answer',
            hintStyle: const TextStyle(color: Colors.white30),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (!widget.isAnswered)
          ElevatedButton(
            onPressed: () {
              final userAnswer = _controller.text.trim().toLowerCase();
              final isCorrect = userAnswer == widget.correctAnswer.trim().toLowerCase();
              widget.onSubmit(isCorrect, userAnswer);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE62E53),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Submit Answer'),
          )
      ],
    );
  }
}