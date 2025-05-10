import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/summary_stats_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late final String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<List<Map<String, dynamic>>> _fetchChapterStats() async {
    if (userId == null) return [];

    final snap = await FirebaseFirestore.instance
        .collection('user_chapter_performance')
        .where('uid', isEqualTo: userId)
        .where('class', isEqualTo: 6)
        .where('subject', isEqualTo: 'Math')
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      final carved = Map<String, dynamic>.from(data['carved_scores'] ?? {});
      return {
        'chapter': data['chapter'],
        'coverage': (carved['C'] ?? 0.0) * 100,
        'accuracy': (carved['A'] ?? 0.0) * 100,
        'lastUpdated': data['last_updated']
      };
    }).toList();
  }

  void _showTopicInsightsSheet(BuildContext context, String chapterName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return _TopicInsightsBody(
            chapter: chapterName,
            userId: userId!,
            scrollController: scrollController,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM, h:mm a');

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SummaryStatsCard(userId: userId!),
          const SizedBox(height: 24),
          Text('Chapter-wise Performance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchChapterStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final chapters = snapshot.data ?? [];
              if (chapters.isEmpty) return const Text('No data yet.');

              return Column(
                children: chapters.map((ch) {
                  final lastUpdated = ch['lastUpdated'] != null
                      ? dateFormat.format((ch['lastUpdated'] as Timestamp).toDate())
                      : '—';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(ch['chapter']),
                      subtitle: Text(
                          'Coverage: ${ch['coverage'].toStringAsFixed(1)}% • Accuracy: ${ch['accuracy'].toStringAsFixed(1)}%'),
                      trailing: Text(lastUpdated, style: const TextStyle(fontSize: 12)),
                      onTap: () => _showTopicInsightsSheet(context, ch['chapter']),
                    ),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}

class _TopicInsightsBody extends StatelessWidget {
  final String chapter;
  final String userId;
  final ScrollController scrollController;

  const _TopicInsightsBody({
    required this.chapter,
    required this.userId,
    required this.scrollController,
  });

  Future<List<Map<String, dynamic>>> _fetchTopicStats() async {
    final firestore = FirebaseFirestore.instance;

    final topicSnap = await firestore
        .collection('topics')
        .where('class', isEqualTo: 6)
        .where('subject', isEqualTo: 'Math')
        .where('chapter', isEqualTo: chapter)
        .get();

    final topics = <Map<String, dynamic>>[];

    for (final doc in topicSnap.docs) {
      final topicId = doc.id;
      final topicName = doc['topic'];

      final userTopicDoc = await firestore
          .collection('user_topic_performance')
          .doc('${userId}_$topicId')
          .get();

      final userData = userTopicDoc.exists ? userTopicDoc.data()! : {};
      final carved = Map<String, dynamic>.from(userData['carved_scores'] ?? {});

      topics.add({
        'topic': topicName,
        'coverage': (carved['C'] ?? 0.0) * 100,
        'accuracy': (carved['A'] ?? 0.0) * 100,
      });
    }

    return topics;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTopicStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final topics = snapshot.data!;
          return ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(chapter, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              if (topics.isEmpty)
                const Text("No topics available."),
              if (topics.isNotEmpty)
                ...topics.map((topic) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(topic['topic'],
                                  maxLines: 2, overflow: TextOverflow.ellipsis)),
                          Text('${topic['coverage'].toStringAsFixed(0)}%',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 16),
                          Text('${topic['accuracy'].toStringAsFixed(0)}%',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }
}