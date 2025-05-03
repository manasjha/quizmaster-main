import 'package:flutter/material.dart';
import 'attempt_question_tile.dart';

class AttemptDetailsPopup extends StatelessWidget {
  final Map<String, dynamic> attemptData;
  final VoidCallback onClose;

  const AttemptDetailsPopup({
    super.key,
    required this.attemptData,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final responses = attemptData['responses'] as List<dynamic>? ?? [];
    final correct = responses.where((r) => r['is_correct'] == true).length;
    final total = responses.length;
    final accuracy = total > 0 ? ((correct / total) * 100).round() : 0;
    final totalTime = attemptData['total_time_taken_seconds'] ?? 0;

    return SafeArea(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.95,
          color: Colors.white,
          child: Column(
            children: [
              // 🔼 Custom AppBar
              Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${attemptData['is_diagnostic'] == true ? 'Diagnostic' : 'Custom'} | ${attemptData['start_time_ist'] ?? ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),

              // Subtitle + Stats
              Container(
                color: Colors.grey.shade100,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Class 6 / Math',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statBox('Total', '$total'),
                          _statBox('Correct', '$correct'),
                          _statBox('Accuracy', '$accuracy%'),
                          _statBox('Time', '${totalTime}s'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Question List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: responses.length,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return AttemptQuestionTile(response: responses[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }
}