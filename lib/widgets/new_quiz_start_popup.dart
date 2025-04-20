// NewQuizStartPopup with black background & horizontal chapter scroll
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NewQuizStartPopup extends StatefulWidget {
  final int quizNumber;
  const NewQuizStartPopup({super.key, required this.quizNumber});

  @override
  State<NewQuizStartPopup> createState() => _NewQuizStartPopupState();
}

class _NewQuizStartPopupState extends State<NewQuizStartPopup> with SingleTickerProviderStateMixin {
  int selectedOption = 1;
  List<String> selectedChapters = ["Knowing Our Numbers", "Whole Numbers"];
  int questionCount = 10;

  late String _dots;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _dots = '';
    _ticker = createTicker((elapsed) {
      final count = (elapsed.inMilliseconds ~/ 1000) % 4;
      if (mounted) {
        setState(() {
          _dots = '.' * count;
        });
      }
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 250,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: const Color(0xFFE62E53), width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Initializing Quiz #${widget.quizNumber}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      ...List.generate(3, (i) {
                        return Row(
                          children: [
                            AnimatedOpacity(
                              opacity: _dots.length > i ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: const Text(".", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            if (i < 2) const SizedBox(width: 4),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildOptionCard(
                  index: 1,
                  title: "Diagnostic",
                  subtitle: "Answer randomly chosen questions to help Isylsi identify your base level in Class 6 Math",
                  questionCount: "20 Questions",
                  difficulty: "Difficulty: Random",
                ),
                const SizedBox(height: 12),
                _buildCustomOption(),
                const SizedBox(height: 12),
                _buildEyeOfIsylsiOption(),
                const SizedBox(height: 24),
                _buildStartButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required int index,
    required String title,
    required String subtitle,
    required String questionCount,
    required String difficulty,
  }) {
    final isSelected = selectedOption == index;
    return GestureDetector(
      onTap: () => setState(() => selectedOption = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.greenAccent.withOpacity(0.1) : Colors.black,
          border: Border.all(
            color: isSelected ? Colors.greenAccent : Colors.grey.shade700,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 12),
            Text(questionCount, style: const TextStyle(fontSize: 12, color: Colors.white54)),
            Text(difficulty, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomOption() {
    final isSelected = selectedOption == 2;
    return GestureDetector(
      onTap: () => setState(() => selectedOption = 2),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.greenAccent.withOpacity(0.1) : Colors.black,
          border: Border.all(
            color: isSelected ? Colors.greenAccent : Colors.grey.shade700,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Custom [${selectedChapters.length} Chapters Selected]", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: selectedChapters.map((chapter) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(chapter, style: const TextStyle(color: Colors.white)),
                        const SizedBox(width: 6),
                        const Text("0%", style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text("Questions:", style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  dropdownColor: Colors.grey.shade900,
                  value: questionCount,
                  iconEnabledColor: Colors.white,
                  style: const TextStyle(color: Colors.white),
                  items: [5, 10, 15, 20, 25, 30].map((value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text("$value"),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => questionCount = value!),
                ),
                const SizedBox(width: 12),
                const Text("Difficulty: Upto Medium", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white54)),
                const Spacer(),
                IconButton(
                  icon: Icon(LucideIcons.settings, size: 18, color: isSelected ? Colors.white70 : Colors.white24),
                  onPressed: isSelected ? _showChapterSelectionDialog : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEyeOfIsylsiOption() {
    final isSelected = false;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(color: isSelected ? Colors.greenAccent : Colors.grey.shade700, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Opacity(
        opacity: isSelected ? 1 : 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Eye of Isylsi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Icon(Icons.lock_outline, size: 18, color: Colors.white),
              ],
            ),
            SizedBox(height: 6),
            Text("Attempt 50 Class 6 Math questions to unlock", style: TextStyle(fontSize: 13, color: Colors.white70)),
            SizedBox(height: 12),
            Text("15 Questions", style: TextStyle(fontSize: 12, color: Colors.white54)),
            Text("Difficulty: AI", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    final label = "Start Quiz";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE62E53),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: selectedOption == 3 ? null : () => Navigator.of(context).pop(),
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showChapterSelectionDialog() {}
}