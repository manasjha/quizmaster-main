import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class MatchTheFollowingWidget extends StatefulWidget {
  final List<String> columnA;
  final List<String> columnB;
  final Map<String, String> correctAnswer;
  final bool isAnswered;
  final Function(bool isCorrect, Map<String, String> userMatch) onSubmit;

  const MatchTheFollowingWidget({
    super.key,
    required this.columnA,
    required this.columnB,
    required this.correctAnswer,
    required this.isAnswered,
    required this.onSubmit,
  });

  @override
  State<MatchTheFollowingWidget> createState() => _MatchTheFollowingWidgetState();
}

class _MatchTheFollowingWidgetState extends State<MatchTheFollowingWidget> {
  String? selectedA;
  Map<String, String> userMatch = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Match the Following",
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: widget.columnA.map((a) {
                  final isSelected = a == selectedA;
                  final isMatched = userMatch.containsKey(a);
                  return GestureDetector(
                    onTap: widget.isAnswered
                        ? null
                        : () => setState(() => selectedA = a),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.pink
                            : isMatched
                                ? Colors.green
                                : Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(a, style: const TextStyle(color: Colors.white)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: widget.columnB.map((b) {
                  final isMatched = userMatch.containsValue(b);
                  return GestureDetector(
                    onTap: widget.isAnswered || selectedA == null
                        ? null
                        : () {
                            setState(() {
                              userMatch[selectedA!] = b;
                              selectedA = null;
                            });
                          },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMatched ? Colors.green : Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(b, style: const TextStyle(color: Colors.white)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!widget.isAnswered)
          ElevatedButton(
            onPressed: () {
              final isCorrect = MapEquality().equals(userMatch, widget.correctAnswer);
              widget.onSubmit(isCorrect, userMatch);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE62E53),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Submit Match"),
          ),
      ],
    );
  }
}