import 'package:flutter/material.dart';

class AttemptQuestionTile extends StatelessWidget {
  final Map<String, dynamic> response;

  const AttemptQuestionTile({
    super.key,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = response['is_correct'] == true;
    final questionText = response['question_text'] ?? '—';
    final selected = response['selected_answer'] ?? '—';
    final correct = response['correct_answer'] ?? '—';
    final topic = response['topic'] ?? '—';
    final chapter = response['chapter'] ?? '—';
    final timeTaken = response['time_taken_seconds'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFDFF5E1) : const Color(0xFFFFE5E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green.shade400 : Colors.red.shade400,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + question
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  questionText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _rowText('Your Answer', selected.toString()),
          _rowText('Correct Answer', correct.toString()),
          _rowText('Topic', topic),
          _rowText('Chapter', chapter),
          _rowText('Time Taken', '${timeTaken}s'),
        ],
      ),
    );
  }

  Widget _rowText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}