import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class PerformanceUpdaterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> runForUserAndSubject({
    required String userId,
    required int userClass,
    required String subject,
  }) async {
    final stopwatch = Stopwatch()..start();
    print("🧠 Running Performance Updater for $userId | Class $userClass | $subject...");

    final snapshot = await _firestore
        .collection('user_topic_performance')
        .where('uid', isEqualTo: userId)
        .where('class', isEqualTo: userClass)
        .where('subject', isEqualTo: subject)
        .get();

    final topicIds = snapshot.docs.map((d) => d['topic_id']).toList();
    final topicMetaSnapshot = await _firestore
        .collection('topics')
        .where(FieldPath.documentId, whereIn: topicIds)
        .get();

    final topicIdToChapter = {
      for (var doc in topicMetaSnapshot.docs)
        doc.id: doc['chapter'] ?? 'Unknown',
    };

    final topicDataList = <Map<String, dynamic>>[];
    final chaptersSet = <String>{};
    int totalAttempted = 0;
    int totalCorrect = 0;
    DateTime? lastAttempted;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final topicId = data['topic_id'];
      final chapter = topicIdToChapter[topicId] ?? 'Unknown';
      final carvedFields = await _computeCARVEDScores(
        data: data,
        userId: userId,
        topicId: topicId,
      );

      final updatedData = {
        ...data,
        'chapter': chapter,
        'carved_scores': carvedFields['carved_scores']
      };
      topicDataList.add(updatedData);
      chaptersSet.add(chapter);

      totalAttempted += (data['attempted'] ?? 0) as int;
      totalCorrect += (data['correct'] ?? 0) as int;

      if (data['last_attempted'] != null) {
        final ts = (data['last_attempted'] as Timestamp).toDate();
        if (lastAttempted == null || ts.isAfter(lastAttempted)) {
          lastAttempted = ts;
        }
      }

      await _firestore.collection('user_topic_performance').doc(doc.id).update({
        'carved_scores': carvedFields['carved_scores'],
      });

      print("🧪 Preview CARVED for topic ${doc.id}: ${_prettyPrint(carvedFields['carved_scores'])}");
    }

    await _computeChapterLevelCARVED(topicDataList);

    final userPerformanceId = "${userId}_class${userClass}_$subject";
    await _firestore.collection('user_performance').doc(userPerformanceId).set({
      'uid': userId,
      'class': userClass,
      'subject': subject,
      'attempted': totalAttempted,
      'correct': totalCorrect,
      'accuracy_score': totalAttempted == 0 ? 0.0 : (100.0 * totalCorrect / totalAttempted),
      'last_attempted': lastAttempted != null ? Timestamp.fromDate(lastAttempted) : null,
      'topics_covered': topicIds,
      'chapters_covered': chaptersSet.toList(),
      'last_updated': FieldValue.serverTimestamp(),
    });
    print("📊 user_performance updated for $userPerformanceId");

    stopwatch.stop();
    print("✅ Completed CARVED score preview in ${stopwatch.elapsedMilliseconds} ms "
          "(${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} sec)");
  }

  Future<Map<String, dynamic>> _computeCARVEDScores({
    required Map<String, dynamic> data,
    required String userId,
    required String topicId,
  }) async {
    final coverage = (data['attempted'] ?? 0) > 0 ? 1.0 : 0.0;
    final accuracy = ((data['accuracy_score'] ?? 0) as num) / 100.0;
    final recency = _computeRecency(data['last_attempted']);
    final volatility = await _computeVolatility(userId: userId, topicId: topicId);
    final excellence = _computeExcellence(data);
    final decay = _computeDecay(data['last_attempted']);

    return {
      'carved_scores': {
        'C': coverage,
        'A': accuracy,
        'R': recency,
        'V': volatility,
        'E': excellence,
        'D': decay,
      }
    };
  }

  Future<void> _computeChapterLevelCARVED(List<Map<String, dynamic>> topicDataList) async {
    final groupedByChapter = <String, List<Map<String, dynamic>>>{};

    for (final data in topicDataList) {
      final chapter = data['chapter'] ?? 'Unknown';
      groupedByChapter.putIfAbsent(chapter, () => []).add(data);
    }

    for (final entry in groupedByChapter.entries) {
      final chapter = entry.key;
      final topics = entry.value;

      final attempted = topics.map((t) => (t['attempted'] ?? 0) as num).fold<int>(0, (a, b) => a + b.toInt());
      final correct = topics.map((t) => ((t['accuracy_score'] ?? 0) as num) / 100.0 * ((t['attempted'] ?? 0) as num)).fold<double>(0.0, (a, b) => a + b);
      final accuracy = attempted == 0 ? 0.0 : correct / attempted;
      final excellence = accuracy;
      final coverage = attempted > 0 ? 1.0 : 0.0;
      final recency = 1.0;
      final decay = 1.0;
      final volatility = 0.0;

      final carved = {
        'C': coverage,
        'A': accuracy,
        'R': recency,
        'V': volatility,
        'E': excellence,
        'D': decay,
      };

      print("📚 Chapter: $chapter");
      carved.forEach((k, v) => print("$k: ${v.toStringAsFixed(2)}"));
      print("");

      final docId = "${topics.first['uid']}_class${topics.first['class']}_${topics.first['subject']}_$chapter";
      await _firestore.collection('user_chapter_performance').doc(docId).set({
        'uid': topics.first['uid'],
        'class': topics.first['class'],
        'subject': topics.first['subject'],
        'chapter': chapter,
        'carved_scores': carved,
        'last_updated': FieldValue.serverTimestamp(),
      });
      print("📘 user_chapter_performance updated for $docId");
    }
  }

  double _computeRecency(Timestamp? lastAttempted) {
    if (lastAttempted == null) return 0.0;
    final now = DateTime.now();
    final diffDays = now.difference(lastAttempted.toDate()).inDays;
    return 1 / (1 + diffDays / 7);
  }

  double _computeDecay(Timestamp? lastAttempted) {
    if (lastAttempted == null) return 0.0;
    final now = DateTime.now();
    final daysAgo = now.difference(lastAttempted.toDate()).inDays;
    return exp(-daysAgo / 14);
  }

  double _computeExcellence(Map<String, dynamic> data) {
    final accuracy = ((data['accuracy_score'] ?? 0) as num) / 100.0;
    return accuracy;
  }

  Future<double> _computeVolatility({
    required String userId,
    required String topicId,
  }) async {
    final snapshot = await _firestore
        .collection('quiz_attempts')
        .where('uid', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();

    final accuracies = <double>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final topicStats = data['topic_stats'];
      if (topicStats != null && topicStats is Map && topicStats.containsKey(topicId)) {
        final topicData = topicStats[topicId];
        if (topicData is Map && topicData.containsKey('accuracy')) {
          final acc = topicData['accuracy'];
          if (acc is num) accuracies.add(acc.toDouble());
        }
      }
    }

    if (accuracies.length < 2) return 0.0;
    final mean = accuracies.reduce((a, b) => a + b) / accuracies.length;
    final variance = accuracies.map((a) => pow(a - mean, 2)).reduce((a, b) => a + b) / accuracies.length;
    final stddev = sqrt(variance);

    return min(stddev / 100.0, 1.0);
  }

  String _prettyPrint(Map? carved) {
    if (carved == null) return 'null';
    return carved.entries.map((e) => "${e.key}: ${(e.value as double).toStringAsFixed(2)}").join(", ");
  }
}