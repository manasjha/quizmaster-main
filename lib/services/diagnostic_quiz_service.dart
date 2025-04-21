import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

Future<List<Map<String, dynamic>>> generateDiagnosticQuiz({
  required int classNum,
  required String subject,
}) async {
  final firestore = FirebaseFirestore.instance;

  // Fetch all diagnostic questions for the given class and subject
  final querySnapshot = await firestore
      .collection('questions_master')
      .where('class', isEqualTo: classNum)
      .where('subject', isEqualTo: subject)
      .where('is_diagnostic', isEqualTo: true)
      .get();

  final allQuestions = querySnapshot.docs.map((doc) => doc.data()).toList();

  // Shuffle to ensure randomness
  allQuestions.shuffle(Random());

  // Pick exactly 20 questions
  return allQuestions.take(20).toList();
}