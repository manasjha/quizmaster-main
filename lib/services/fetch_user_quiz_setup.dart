import 'package:cloud_firestore/cloud_firestore.dart';

class UserQuizSetupResult {
  final int quizzesAttempted;
  final int aiQuizzesAvailable;
  final List<String> selectedChapters;
  final List<String> otherChapters;

  UserQuizSetupResult({
    required this.quizzesAttempted,
    required this.aiQuizzesAvailable,
    required this.selectedChapters,
    required this.otherChapters,
  });
}

Future<UserQuizSetupResult> fetchUserQuizSetup({
  required String userId,
  required int classNum,
  required String subject,
}) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Normalize subject (e.g., "math" → "Math")
  final normalizedSubject = subject[0].toUpperCase() + subject.substring(1).toLowerCase();

  // 1. Fetch quizzes_attempted and ai_quizzes_available
  final performanceDocId = "${userId}_class${classNum}_${subject.toLowerCase()}";
  final performanceSnap = await firestore
      .collection('user_performance')
      .doc(performanceDocId)
      .get();

  final quizzesAttempted = performanceSnap.data()?['quizzes_attempted'] ?? 0;
  final aiQuizzesAvailable = performanceSnap.data()?['ai_quizzes_available'] ?? 0;

  // 2. Fetch all user_topic_performance for this user-class-subject
  final topicPerfSnap = await firestore
      .collection('user_topic_performance')
      .where('uid', isEqualTo: userId)
      .where('class', isEqualTo: classNum)
      .where('subject', isEqualTo: normalizedSubject)
      .get();

  List<Map<String, dynamic>> recentTopics = topicPerfSnap.docs
      .where((doc) => doc.data()['last_attempted'] != null)
      .map((doc) => doc.data())
      .toList();

  // Sort recent topics by last_attempted descending
  recentTopics.sort((a, b) =>
      (b['last_attempted'] as Timestamp).compareTo(a['last_attempted'] as Timestamp));

  // 3. Fetch all topics to get chapter names
  final topicSnap = await firestore
      .collection('topics')
      .where('class', isEqualTo: classNum)
      .where('subject', isEqualTo: normalizedSubject)
      .get();

  final allChapters = topicSnap.docs.map((doc) => doc['chapter'] as String).toSet().toList();

  // 4. Determine selected + other chapters
  List<String> selectedChapters = [];
  if (recentTopics.isNotEmpty) {
    final recentTopicIds = recentTopics.map((e) => e['topic_id']).toSet();

    final topicIdToChapter = {
      for (var doc in topicSnap.docs) doc.id: doc['chapter']
    };

    selectedChapters = recentTopicIds
        .map((id) => topicIdToChapter[id])
        .whereType<String>()
        .toSet()
        .toList()
        .take(2)
        .toList();
  }

  if (selectedChapters.length < 2 && allChapters.length >= 2) {
    final needed = 2 - selectedChapters.length;
    final fillerChapters = allChapters
        .where((chapter) => !selectedChapters.contains(chapter))
        .take(needed);
    selectedChapters.addAll(fillerChapters);
  }

  final otherChapters = allChapters.where((c) => !selectedChapters.contains(c)).toList();

  return UserQuizSetupResult(
    quizzesAttempted: quizzesAttempted is int ? quizzesAttempted : 0,
    aiQuizzesAvailable: aiQuizzesAvailable is int ? aiQuizzesAvailable : 0,
    selectedChapters: selectedChapters,
    otherChapters: otherChapters,
  );
}