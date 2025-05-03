import 'package:flutter/material.dart';

class AttemptHistoryCard extends StatelessWidget {
  final Map<String, dynamic> attemptData;
  final VoidCallback onTap;

  const AttemptHistoryCard({
    super.key,
    required this.attemptData,
    required this.onTap,
  });

  String formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final startTime = attemptData['start_time_ist'] ?? '-';
    final responses = attemptData['responses'] as List<dynamic>? ?? [];
    final correct = responses.where((r) => r['is_correct'] == true).length;
    final total = responses.length;
    final scorePercent = total > 0 ? ((correct / total) * 100).floor() : 0;
    final timeTaken = attemptData['total_time_taken_seconds'] ?? 0;
    final isDiagnostic = attemptData['is_diagnostic'] ?? false;
    final quizType = isDiagnostic
        ? 'Diagnostic'
        : attemptData['quiz_id'].toString().contains('eye')
            ? 'Eye of Isylsi'
            : 'Custom';

    final uniqueChapters = {
      ...responses.map((r) => r['chapter'] ?? '-')
    }..remove('-');
    final uniqueTopics = {
      ...responses.map((r) => r['topic'] ?? '-')
    }..remove('-');

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.black87,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top row: Date and Quiz Type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    startTime,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    quizType,
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              /// Score Row
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  Text('Correct: $correct', style: const TextStyle(color: Colors.white70)),
                  Text('Total: $total', style: const TextStyle(color: Colors.white70)),
                  Text('Score: $scorePercent%', style: const TextStyle(color: Colors.white70)),
                  Text('Time Taken: ${formatDuration(timeTaken)}', style: const TextStyle(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 10),

              /// Subject and Chapters
              const Text('Subject: Math', style: TextStyle(color: Colors.white70)),
              Text(
                'Chapters: ${uniqueChapters.isEmpty ? '-' : uniqueChapters.join(', ')}',
                style: const TextStyle(color: Colors.white70),
              ),

              /// Topics covered (count)
              const SizedBox(height: 4),
              Text(
                'Topics Covered: ${uniqueTopics.isEmpty ? '-' : uniqueTopics.length}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}