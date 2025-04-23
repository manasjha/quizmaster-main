import 'package:flutter/material.dart';

class TFButtonRow extends StatelessWidget {
  final int? selectedIndex;
  final bool isAnswered;
  final bool isCorrectAnswer;
  final Function(int) onSelect;

  const TFButtonRow({
    super.key,
    required this.selectedIndex,
    required this.isAnswered,
    required this.isCorrectAnswer,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    List<String> labels = ['True', 'False'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(2, (index) {
        bool isSelected = selectedIndex == index;
        bool isCorrect = (isCorrectAnswer && index == 0) || (!isCorrectAnswer && index == 1);
        Color bgColor;

        if (!isAnswered) {
          bgColor = isSelected ? Colors.pink : Colors.grey[900]!;
        } else if (isCorrect) {
          bgColor = Colors.green;
        } else if (isSelected) {
          bgColor = Colors.red;
        } else {
          bgColor = Colors.grey[900]!;
        }

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          ),
          onPressed: () => onSelect(index),
          child: Text(labels[index], style: const TextStyle(color: Colors.white)),
        );
      }),
    );
  }
}