import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryStatsCard extends StatefulWidget {
  final String userId;
  const SummaryStatsCard({super.key, required this.userId});

  @override
  State<SummaryStatsCard> createState() => _SummaryStatsCardState();
}

class _SummaryStatsCardState extends State<SummaryStatsCard> {
  late Future<Map<String, dynamic>> _futureStats;

  @override
  void initState() {
    super.initState();
    _futureStats = _fetchStats();
  }

  Future<Map<String, dynamic>> _fetchStats() async {
    final firestore = FirebaseFirestore.instance;

    // 1. Read from cleaned user_performance doc
    final perfSnap = await firestore
        .collection('user_performance')
        .doc('${widget.userId}_class6_Math')
        .get();

    final perfData = perfSnap.data()!;
    final accuracy = perfData['accuracy_score'] ?? 0.0;
    final lastActive = perfData['last_attempted'];
    final quizzesAttempted = perfData['quizzes_attempted'] ?? 0;

    // 2. Compute average coverage from all chapters
    final chaptersSnap = await firestore
        .collection('user_chapter_performance')
        .where('uid', isEqualTo: widget.userId)
        .where('class', isEqualTo: 6)
        .where('subject', isEqualTo: 'Math')
        .get();

    final coverageList = chaptersSnap.docs
        .map((doc) => (doc['carved_scores']?['C'] ?? 0.0) as double)
        .toList();

    final avgCoverage = coverageList.isEmpty
        ? 0.0
        : (coverageList.reduce((a, b) => a + b) / coverageList.length) * 100;

    return {
      'accuracy': accuracy,
      'coverage': avgCoverage,
      'quizzes': quizzesAttempted,
      'lastActive': lastActive,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _futureStats,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;
        final formatter = DateFormat('dd MMM yyyy, h:mm a');
        final lastActiveFormatted = stats['lastActive'] != null
            ? formatter.format((stats['lastActive'] as Timestamp).toDate())
            : '—';

        return Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Performance Summary', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _buildStatRow('Accuracy', '${stats['accuracy'].toStringAsFixed(1)}%'),
                _buildStatRow('Coverage', '${stats['coverage'].toStringAsFixed(1)}%'),
                _buildStatRow('Quizzes Attempted', '${stats['quizzes']}'),
                _buildStatRow('Last Active', lastActiveFormatted),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}