import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:quizmaster/widgets/question_header.dart';
import 'package:quizmaster/widgets/options_grid.dart';
import 'package:quizmaster/widgets/tf_button_row.dart';
import 'package:quizmaster/widgets/match_the_following.dart';
import 'package:collection/collection.dart';
import 'package:quizmaster/widgets/fill_in_the_blank.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:quizmaster/services/scoring_service.dart';
import 'package:quizmaster/services/performance_updater.dart';

class QuestionResponse {
  final String questionId;
  final dynamic selectedAnswer;
  final dynamic correctAnswer;
  final bool isCorrect;
  final double timeTakenSeconds;
  final String topic;
  final String chapter;
  final String questionText;

  QuestionResponse({
    required this.questionId,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.timeTakenSeconds,
    required this.topic,
    required this.chapter,
    required this.questionText,
  });

  Map<String, dynamic> toMap() {
    return {
      'question_id': questionId,
      'selected_answer': selectedAnswer,
      'correct_answer': correctAnswer,
      'is_correct': isCorrect,
      'time_taken_seconds': timeTakenSeconds,
      'topic': topic,
      'chapter': chapter,
      'question_text': questionText,
    };
  }
}


class QuizScreen extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final String quizTitle;
  final bool isDiagnostic;

  const QuizScreen({
    super.key,
    required this.questions,
    required this.quizTitle,
    required this.isDiagnostic,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  late AnimationController _timerController;
  late Animation<double> _progressAnimation;

  int currentIndex = 0;
  int? selectedOptionIndex;
  bool isAnswered = false;
  bool isCorrect = false;
  bool showNextButton = false;

  List<int> timeTakenPerQuestion = [];
  List<QuestionResponse> responses = [];
  Map<String, String> userMatch = {};
  final int questionDuration = 30;
  TextEditingController textController = TextEditingController();
  Set<int> _loggedIndexes = {};

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: questionDuration),
    );

    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_timerController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && !isAnswered) {
          timeTakenPerQuestion.add(questionDuration);
        }
      });

    _startTimer();
  }

  void _startTimer() {
    _timerController.reset();
    _timerController.forward();
  }

  void _goToNextQuestion() {
  final currentQuestion = widget.questions[currentIndex];
  final format = currentQuestion['format'];
  final options = currentQuestion['options'] as List<dynamic>? ?? [];
  final correctAnswer = currentQuestion['answer'];
  final topic = currentQuestion['topic'] ?? '-';
  final chapter = currentQuestion['chapter'] ?? '-';
  final questionText = currentQuestion['question_text'] ?? '-';

  dynamic selectedAnswer;
  bool isAnswerCorrect = false;

  if (format == 'Fill in the Blank') {
    selectedAnswer = textController.text.trim();
    isAnswerCorrect = selectedAnswer.toLowerCase() == correctAnswer.toString().toLowerCase();
  } else if (format == 'Match the Following') {
    selectedAnswer = userMatch;
    isAnswerCorrect = MapEquality().equals(selectedAnswer, correctAnswer);
  } else {
    if (selectedOptionIndex != null && selectedOptionIndex! < options.length) {
      selectedAnswer = options[selectedOptionIndex!];
      isAnswerCorrect = selectedAnswer == correctAnswer;
    }
  }

  final elapsed = (questionDuration * (1.0 - _progressAnimation.value)).floor();
  timeTakenPerQuestion.add(elapsed);

  final response = QuestionResponse(
    questionId: currentQuestion['question_id'],
    selectedAnswer: selectedAnswer,
    correctAnswer: correctAnswer,
    isCorrect: isAnswerCorrect,
    timeTakenSeconds: elapsed.toDouble(),
    topic: topic,
    chapter: chapter,
    questionText: questionText,
  );

  responses.add(response);
  print("📩 User answered Q${currentIndex + 1} | Correct: $isAnswerCorrect | Answer: $selectedAnswer");

  if (currentIndex < widget.questions.length - 1) {
    setState(() {
      currentIndex++;
      selectedOptionIndex = null;
      isAnswered = false;
      isCorrect = false;
      showNextButton = false;
    });
    _startTimer();
  } else {
    _uploadQuizAttempt();
    Navigator.pop(context);
  }
}


  Future<void> _uploadQuizAttempt() async {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("❌ User not logged in!");
      return;
    }
    final userId = user.uid;
    final quizId = "${userId}_${DateTime.now().millisecondsSinceEpoch}";

    final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    final formattedStartTime = DateFormat('d MMM yyyy, hh:mm a').format(now);

    await firestore.collection('quiz_attempts').doc(quizId).set({
      'user_id': userId,
      'quiz_id': quizId,
      'start_time_ist': formattedStartTime,
      'total_time_taken_seconds': timeTakenPerQuestion.fold<int>(0, (a, b) => a + b),
      'is_diagnostic': widget.isDiagnostic,
      'timestamp': FieldValue.serverTimestamp(),
      'responses': responses.map((r) => r.toMap()).toList(),
    });

    print("✅ Quiz attempt uploaded!");
    print("📊 Final Quiz Responses:");
    for (var r in responses) {
      print(r.toMap());
    }

    await ScoringService().processQuizResults(
      userId: userId,
      responses: responses,
      userClass: 6,
      subject: 'Math',
    );

    await PerformanceUpdaterService().runForUserAndSubject(
      userId: userId,
      userClass: 6,
      subject: 'Math',
    );
  }

  void handleAnswer(int index, List<dynamic> options, dynamic correctAnswer) {
    if (isAnswered) return;

    final selected = options[index];
    final isAnswerCorrect = selected == correctAnswer;

    final elapsed = (questionDuration * (1.0 - _progressAnimation.value)).floor();
    timeTakenPerQuestion.add(elapsed);
    _timerController.stop();

    setState(() {
      selectedOptionIndex = index;
      isAnswered = true;
      isCorrect = isAnswerCorrect;
      showNextButton = !isAnswerCorrect;
    });

    print("📩 User selected option ${index + 1}: $selected | Correct: $isAnswerCorrect");

    showToast(context, isAnswerCorrect ? "Correct!" : "Incorrect!");
    if (isAnswerCorrect) {
      Future.delayed(const Duration(seconds: 2), _goToNextQuestion);
    }
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[currentIndex];

    if (!_loggedIndexes.contains(currentIndex)) {
      _loggedIndexes.add(currentIndex);
      print("🟡 Q${currentIndex + 1} | Format: ${currentQuestion['format']}");
      print("🔹 Question Text: ${currentQuestion['question_text']}");
      print("🔸 Options: ${currentQuestion['options']}");
      print("🔸 Column A: ${currentQuestion['column_a']}");
      print("🔸 Column B: ${currentQuestion['column_b']}");
      print("🔸 Answer: ${currentQuestion['answer']}");
    }

    final options = currentQuestion['options'] as List<dynamic>? ?? [];
    final correctAnswer = currentQuestion['answer'];
    final explanation = currentQuestion['explanation'];

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: showNextButton
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFFE62E53),
              icon: const Icon(Icons.arrow_forward),
              label: const Text("Next"),
              onPressed: _goToNextQuestion,
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            QuestionHeader(
              currentQuestion: currentIndex + 1,
              totalQuestions: widget.questions.length,
              topic: currentQuestion['topic'] ?? 'Unknown',
              progress: _progressAnimation.value,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      currentQuestion['question_text'] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: currentQuestion['format'] == 'True/False'
                  ? TFButtonRow(
                      selectedIndex: selectedOptionIndex,
                      isAnswered: isAnswered,
                      isCorrectAnswer: correctAnswer.toString().toLowerCase() == 'true',
                      onSelect: (index) {
                        final tfOptions = ['True', 'False'];
                        handleAnswer(index, tfOptions, correctAnswer);
                      },
                    )
                  : currentQuestion['format'] == 'Match the Following'
                      ? MatchTheFollowingWidget(
                          columnA: List<String>.from(currentQuestion['column_a'] ?? []),
                          columnB: List<String>.from(currentQuestion['column_b'] ?? []),
                          correctAnswer: Map<String, String>.from(currentQuestion['answer'] ?? {}),
                          isAnswered: isAnswered,
                          onSubmit: (bool isCorrectNow, Map<String, String> submittedMatch) {
                            final elapsed = (questionDuration * (1.0 - _progressAnimation.value)).floor();
                            timeTakenPerQuestion.add(elapsed);
                            _timerController.stop();

                            setState(() {
                              userMatch = submittedMatch;
                              selectedOptionIndex = null;
                              isAnswered = true;
                              isCorrect = isCorrectNow;
                              showNextButton = !isCorrectNow;
                            });

                            showToast(context, isCorrectNow ? "Correct!" : "Incorrect!");

                            if (isCorrectNow) {
                              Future.delayed(const Duration(seconds: 2), _goToNextQuestion);
                            }
                          })
                      : currentQuestion['format'] == 'Fill in the Blank'
                          ? FillInTheBlankWidget(
                              correctAnswer: correctAnswer.toString(),
                              isAnswered: isAnswered,
                              onSubmit: (bool isCorrectNow, String userInput) {
                                final elapsed = (questionDuration * (1.0 - _progressAnimation.value)).floor();
                                timeTakenPerQuestion.add(elapsed);
                                _timerController.stop();

                                setState(() {
                                  textController.text = userInput;
                                  selectedOptionIndex = null;
                                  isAnswered = true;
                                  isCorrect = isCorrectNow;
                                  showNextButton = !isCorrectNow;
                                });

                                showToast(context, isCorrectNow ? "Correct!" : "Incorrect!");

                                if (isCorrectNow) {
                                  Future.delayed(const Duration(seconds: 2), _goToNextQuestion);
                                }
                              })
                          : OptionsGrid(
                              options: options.map((e) => e.toString()).toList(),
                              selectedIndex: selectedOptionIndex,
                              correctIndex: options.indexOf(correctAnswer),
                              isAnswered: isAnswered,
                              onSelect: (index) => handleAnswer(index, options, correctAnswer),
                            ),
            ),
            if (isAnswered && !isCorrect && explanation != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Explanation',
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        explanation,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

void showToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 60,
      left: MediaQuery.of(context).size.width * 0.2,
      width: MediaQuery.of(context).size.width * 0.6,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
}