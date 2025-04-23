import 'package:flutter/material.dart';
import 'option_button.dart';

class OptionsGrid extends StatelessWidget {
  final List<String> options;
  final int? selectedIndex;
  final int correctIndex;
  final bool isAnswered;
  final Function(int) onSelect;

  const OptionsGrid({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.correctIndex,
    required this.isAnswered,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int row = 0; row < 2; row++)
          Row(
            children: [
              for (int col = 0; col < 2; col++)
                if ((row * 2 + col) < options.length)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      child: OptionButton(
                        text: options[row * 2 + col],
                        isSelected: selectedIndex == row * 2 + col,
                        isAnswered: isAnswered,
                        isCorrectAnswer: correctIndex == row * 2 + col,
                        onTap: () => onSelect(row * 2 + col),
                      ),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
            ],
          ),
      ],
    );
  }
}