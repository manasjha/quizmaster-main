import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/quiz_screen.dart'; // For QuestionResponse
import 'package:collection/collection.dart';

class ScoringService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const bool auditMode = false;
  static const bool debugMode = true;

  Future<void> processQuizResults({
    required String userId,
    required List<QuestionResponse> responses,
    required int userClass,
    required String subject,
  }) async {
    print("🚀 Starting new scoring service...");
    final stopwatch = Stopwatch()..start();

    final questionIds = responses.map((r) => r.questionId).toSet().toList();

    // 1. Fetch all questions in parallel
    final questionDocs = await Future.wait(
      questionIds.map((id) => _firestore.collection('questions_master').doc(id).get())
    );
    final questionMap = {
      for (var doc in questionDocs)
        if (doc.exists) doc.id: doc.data()!..['id'] = doc.id
    };

    if (debugMode) {
      print("📦 Loaded ${questionMap.length} / ${questionIds.length} questions");
    }

    int totalCorrect = 0;
    int totalAttempted = 0;
    int questionsSkipped = 0;
    final Map<String, Map<String, int>> topicStats = {}; // topicId -> {attempted, correct}
    final Set<String> topicsAttemptedThisQuiz = {};

    final List<WriteBatch> batches = [];
    WriteBatch currentBatch = _firestore.batch();
    int batchOpCount = 0;

    void commitBatchIfFull() {
      if (batchOpCount >= 450) {
        batches.add(currentBatch);
        currentBatch = _firestore.batch();
        batchOpCount = 0;
      }
    }

    for (final response in responses) {
      final questionData = questionMap[response.questionId];
      if (questionData == null) {
        print("❌ Skipping missing question: ${response.questionId}");
        questionsSkipped++;
        continue;
      }

      final topicId = questionData['topic_id'] as String?;
      if (topicId == null) {
        print("❌ Skipping question with no topic: ${response.questionId}");
        questionsSkipped++;
        continue;
      }

      topicsAttemptedThisQuiz.add(topicId);

      // Optional audit
      if (auditMode) {
        final correct = response.correctAnswer;
        final selected = response.selectedAnswer;
        final format = questionData['format'];
        final isActuallyCorrect = () {
          if (format == 'Match the Following') {
            return const DeepCollectionEquality().equals(selected, correct);
          } else if (format == 'Fill in the Blank') {
            return selected.toString().trim().toLowerCase() == correct.toString().trim().toLowerCase();
          } else {
            return selected == correct;
          }
        }();
        if (isActuallyCorrect != response.isCorrect) {
          print("⚠️ AUDIT MISMATCH: ${response.questionId}");
        }
      }

      final isCorrect = response.isCorrect;
      totalAttempted++;
      if (isCorrect) totalCorrect++;

      topicStats.putIfAbsent(topicId, () => {'attempted': 0, 'correct': 0});
      topicStats[topicId]!['attempted'] = topicStats[topicId]!['attempted']! + 1;
      if (isCorrect) topicStats[topicId]!['correct'] = topicStats[topicId]!['correct']! + 1;

      if (debugMode) {
        print("🔹 Processing Q: ${response.questionId} | Topic: $topicId | Correct: $isCorrect");
      }

      // Update questions_master
      final questionRef = _firestore.collection('questions_master').doc(response.questionId);
      currentBatch.update(questionRef, {
        'total_attempts': FieldValue.increment(1),
        if (isCorrect) 'correct_attempts': FieldValue.increment(1),
      });
      batchOpCount++; commitBatchIfFull();

      // Update topics
      final topicRef = _firestore.collection('topics').doc(topicId);
      currentBatch.update(topicRef, {
        'total_attempts': FieldValue.increment(1),
        if (isCorrect) 'correct_attempts': FieldValue.increment(1),
      });
      batchOpCount++; commitBatchIfFull();
    }

    // Update user_performance
    final perfDocId = '${userId}_class${userClass}_${subject.toLowerCase()}';
    final perfRef = _firestore.collection('user_performance').doc(perfDocId);
    final perfSnap = await perfRef.get();
    int previousAttempted = 0;
    int previousCorrect = 0;
    Set<String> previousTopicsAttempted = {};
    final int totalAvailableTopics = 317; // Hardcoded for now

    if (perfSnap.exists) {
      final data = perfSnap.data()!;
      previousAttempted = (data['total_questions_attempted'] ?? 0) as int;
      previousCorrect = (data['total_correct_answers'] ?? 0) as int;
      final List<dynamic>? previousTopics = data['topics_attempted'] as List<dynamic>?;
      if (previousTopics != null) {
        previousTopicsAttempted = previousTopics.whereType<String>().toSet();
      }
    }

    final newTotalAttempted = previousAttempted + totalAttempted;
    final newTotalCorrect = previousCorrect + totalCorrect;
    final updatedTopicsAttempted = previousTopicsAttempted.union(topicsAttemptedThisQuiz);
    final newAccuracy = (newTotalAttempted == 0) ? 0 : (newTotalCorrect / newTotalAttempted) * 100;
    final newCoverage = (totalAvailableTopics == 0) ? 0 : (updatedTopicsAttempted.length / totalAvailableTopics) * 100;

    if (debugMode) {
      print("📊 User Performance → Attempted: $newTotalAttempted, Correct: $newTotalCorrect");
      print("📈 Accuracy: ${newAccuracy.toStringAsFixed(1)}%, Coverage: ${newCoverage.toStringAsFixed(1)}%");
    }

    currentBatch.set(perfRef, {
      'total_questions_attempted': newTotalAttempted,
      'total_correct_answers': newTotalCorrect,
      'accuracy_score': newAccuracy,
      'coverage_score': newCoverage,
      'topics_attempted': updatedTopicsAttempted.toList(),
      'quizzes_attempted': FieldValue.increment(1),
      'last_active': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    batchOpCount++; commitBatchIfFull();

    // Update user_topic_performance
    for (final topicId in topicStats.keys) {
      final docId = '${userId}_$topicId';
      final ref = _firestore.collection('user_topic_performance').doc(docId);
      final snap = await ref.get();

      final prevData = snap.data() ?? {};
      final oldAttempted = (prevData['attempted'] ?? 0) as int;
      final oldCorrect = (prevData['correct'] ?? 0) as int;

      final deltaAttempted = topicStats[topicId]!['attempted']!;
      final deltaCorrect = topicStats[topicId]!['correct']!;
      final newAttempted = oldAttempted + deltaAttempted;
      final newCorrect = oldCorrect + deltaCorrect;
      final topicAccuracy = (newAttempted == 0) ? 0 : (newCorrect / newAttempted) * 100;

      if (debugMode) {
        print("📘 Topic $topicId → Attempted: $newAttempted, Correct: $newCorrect, Accuracy: ${topicAccuracy.toStringAsFixed(1)}%");
      }

      currentBatch.set(ref, {
        'uid': userId,
        'topic_id': topicId,
        'class': userClass,
        'subject': subject,
        'attempted': newAttempted,
        'correct': newCorrect,
        'accuracy_score': topicAccuracy,
        'last_attempted': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      batchOpCount++; commitBatchIfFull();
    }

    // Finalize batches
    batches.add(currentBatch);
    int batchIndex = 1;

    for (final batch in batches) {
      try {
        await batch.commit();
        print("✅ Batch #$batchIndex committed successfully!");
      } catch (e) {
        print("❌ Batch #$batchIndex failed: $e");
      }
      batchIndex++;
    }

    stopwatch.stop();
    print("🎯 Scoring finished in ${stopwatch.elapsedMilliseconds} ms");
    print("✅ Total Correct: $totalCorrect / $totalAttempted | Skipped: $questionsSkipped");
  }
}