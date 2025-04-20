import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChapterSelectionPopup extends StatefulWidget {
  final List<String> initiallySelected;
  final int classNum;
  final String subject;
  final String userId;
  final Function(List<String>) onSave;

  const ChapterSelectionPopup({
    super.key,
    required this.initiallySelected,
    required this.classNum,
    required this.subject,
    required this.userId,
    required this.onSave,
  });

  @override
  State<ChapterSelectionPopup> createState() => _ChapterSelectionPopupState();
}

class _ChapterSelectionPopupState extends State<ChapterSelectionPopup> {
  List<String> selectedChapters = [];
  List<Map<String, dynamic>> chapterStats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedChapters = List.from(widget.initiallySelected);
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    final firestore = FirebaseFirestore.instance;
    final topicsSnap = await firestore
        .collection('topics')
        .where('class', isEqualTo: widget.classNum)
        .where('subject', isEqualTo: widget.subject)
        .get();

    final topics = topicsSnap.docs.map((e) => e.data()).toList();
    final chapters = topics.map((e) => e['chapter'] as String).toSet().toList();

    final perfSnap = await firestore
        .collection('user_topic_performance')
        .where('uid', isEqualTo: widget.userId)
        .get();

    final perfData = perfSnap.docs.map((e) => e.data()).toList();
    final List<Map<String, dynamic>> stats = [];

    for (var chapter in chapters) {
      final chapterTopics = topics.where((t) => t['chapter'] == chapter);
      final topicIds = chapterTopics.map((t) => t['topic_id']).toList();
      final relevant = perfData.where((p) => topicIds.contains(p['topic_id']));

      int totalTopics = chapterTopics.length;
      int attemptedTopics = relevant.where((r) => (r['correct_answers'] ?? 0) > 0).length;

      stats.add({
        'chapter': chapter,
        'progress': totalTopics == 0 ? 0 : ((attemptedTopics / totalTopics) * 100).round(),
        'isSelected': selectedChapters.contains(chapter),
      });
    }

    stats.sort((a, b) {
      if (a['isSelected'] && !b['isSelected']) return -1;
      if (!a['isSelected'] && b['isSelected']) return 1;
      return a['chapter'].compareTo(b['chapter']);
    });

    setState(() {
      chapterStats = stats;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey.shade900,
      insetPadding: const EdgeInsets.all(0),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Create Custom Quiz [Class 6 - Math]",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'monospace'),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Select upto 3 chapters",
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text("Fetching Topics", style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
                    ],
                  ),
                ),
              )
            else ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 40),
                    Expanded(
                      child: Text(
                        "Chapter",
                        style: TextStyle(color: Colors.white70, fontFamily: 'monospace'),
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      child: Center(
                        child: Text(
                          "Progress",
                          style: TextStyle(color: Colors.white70, fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: chapterStats.map((stat) {
                    final isSelected = selectedChapters.contains(stat['chapter']);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Checkbox(
                              value: isSelected,
                              activeColor: Colors.green,
                              onChanged: (val) {
                                if (val == true && selectedChapters.length >= 3) return;
                                setState(() {
                                  if (val == true) {
                                    selectedChapters.add(stat['chapter']);
                                  } else {
                                    selectedChapters.remove(stat['chapter']);
                                  }
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: Text(
                              stat['chapter'],
                              style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 72,
                            child: Center(
                              child: Text(
                                "${stat['progress']}%",
                                style: const TextStyle(color: Colors.white70, fontFamily: 'monospace'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE62E53)),
                        foregroundColor: const Color(0xFFE62E53),
                      ),
                      child: const Text("Cancel", style: TextStyle(fontFamily: 'monospace')),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: selectedChapters.isEmpty
                          ? null
                          : () {
                              widget.onSave(selectedChapters);
                              Navigator.of(context).pop();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE62E53),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Save", style: TextStyle(fontFamily: 'monospace')),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}