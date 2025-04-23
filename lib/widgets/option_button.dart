import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isAnswered;
  final bool isCorrectAnswer;
  final VoidCallback onTap;

  const OptionButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.isAnswered,
    required this.isCorrectAnswer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color getBackgroundColor() {
      if (!isAnswered) return isSelected ? Colors.pink : Colors.grey[900]!;

      if (isCorrectAnswer) return Colors.green;
      if (isSelected) return Colors.red;

      return Colors.grey[900]!;
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: getBackgroundColor(),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}