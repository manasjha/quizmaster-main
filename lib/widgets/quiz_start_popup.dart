import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'quiz_type_card.dart';
import 'custom_quiz_option.dart';

enum QuizStartMode { newUser, repeatUser }

class QuizStartPopup extends StatefulWidget {
  final int quizzesAttempted;
  final int aiQuizzesAvailable;
  final List<String> selectedChapters;

  const QuizStartPopup({
    super.key,
    required this.quizzesAttempted,
    required this.aiQuizzesAvailable,
    required this.selectedChapters,
  });

  @override
  State<QuizStartPopup> createState() => _QuizStartPopupState();
}

class _QuizStartPopupState extends State<QuizStartPopup> with SingleTickerProviderStateMixin {
  late final bool isFirstQuiz;
  late final bool hasAIQuiz;
  late List<String> selectedChapters;
  late int selectedOption; // 1 = Diagnostic, 2 = Custom, 3 = Eye of Isylsi
  bool autoStartActive = false;
  int countdown = 3;
  Ticker? _ticker;
  int dotCount = 0;

  @override
  void initState() {
    super.initState();
    selectedChapters = widget.selectedChapters.toSet().toList();
    if (selectedChapters.length > 2) {
      selectedChapters = selectedChapters.sublist(0, 2);
    }
    isFirstQuiz = widget.quizzesAttempted == 0;
    hasAIQuiz = widget.aiQuizzesAvailable > 0;
    selectedOption = isFirstQuiz ? 1 : hasAIQuiz ? 3 : 2;

    if (!isFirstQuiz) startCountdown();
    _ticker = createTicker((elapsed) {
      dotCount = (elapsed.inMilliseconds ~/ 1000) % 4;
      setState(() {});
      if (autoStartActive && elapsed.inSeconds >= countdown) {
        _ticker?.stop();
        Navigator.of(context).pop();
        // Navigate to quiz screen here
      }
    });
    _ticker?.start();
  }

  void startCountdown() {
    autoStartActive = true;
    countdown = 3;
    setState(() {});
  }

  void cancelCountdown() {
    autoStartActive = false;
    setState(() {});
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        color: Colors.black.withOpacity(0.9),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildCards(),
            const SizedBox(height: 24),
            _buildStartRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final dots = List.generate(3, (i) => i < dotCount ? '.' : ' ').join(' ');
    return Container(
      width: 250,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE62E53), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Initializing Quiz #${widget.quizzesAttempted + 1}  $dots",
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildCards() {
    return Column(
      children: [
        QuizTypeCard(
          state: QuizTypeCardState.expanded,
          isSelected: selectedOption == 1,
          onSelect: () => setState(() => selectedOption = 1),
          title: "Diagnostic",
          subtitle: "Answer randomly chosen questions to help Isylsi identify your base level in Class 6 Math",
          expandedContent: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("20 Questions", style: TextStyle(fontSize: 12, color: Colors.white54)),
              Text("Difficulty: Random", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white54)),
            ],
          ),
        ),
        QuizTypeCard(
          state: QuizTypeCardState.expanded,
          isSelected: selectedOption == 2,
          onSelect: () => setState(() => selectedOption = 2),
          title: "Custom",
          subtitle: "Start a quiz from chapters you've recently studied",
          expandedContent: CustomQuizOption(
            isSelected: selectedOption == 2,
            selectedChapters: selectedChapters,
            questionCount: 10,
            onQuestionCountChanged: (val) {},
            onTap: () => setState(() => selectedOption = 2),
            onSettingsPressed: (updatedChapters) => setState(() => selectedChapters = updatedChapters),
          ),
        ),
        QuizTypeCard(
          state: hasAIQuiz ? QuizTypeCardState.expanded : QuizTypeCardState.locked,
          isSelected: selectedOption == 3,
          onSelect: hasAIQuiz ? () => setState(() => selectedOption = 3) : null,
          title: "Eye of Isylsi",
          subtitle: hasAIQuiz
              ? "AI generated quiz just for you"
              : "Attempt 50 questions to unlock",
          expandedContent: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("15 Questions", style: TextStyle(fontSize: 12, color: Colors.white54)),
              Text("Difficulty: AI", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white54)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            if (autoStartActive) {
              cancelCountdown();
            } else {
              startCountdown();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE62E53),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          ),
          child: Text(
            autoStartActive
                ? "Starting Quiz in $countdown..."
                : "Start Quiz",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
          ),
        ),
        if (autoStartActive)
          TextButton(
            onPressed: cancelCountdown,
            child: const Text("Modify", style: TextStyle(color: Colors.white70)),
          ),
      ],
    );
  }
}