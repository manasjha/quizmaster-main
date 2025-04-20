import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizmaster/widgets/chapterSelectionPopup.dart';

class CustomQuizOption extends StatelessWidget {
  final bool isSelected;
  final List<String> selectedChapters;
  final int questionCount;
  final ValueChanged<int> onQuestionCountChanged;
  final VoidCallback onTap;
  final ValueChanged<List<String>> onSettingsPressed;

  const CustomQuizOption({
    super.key,
    required this.isSelected,
    required this.selectedChapters,
    required this.questionCount,
    required this.onQuestionCountChanged,
    required this.onTap,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              onChanged: (value) => onQuestionCountChanged(value!),
            ),
            const SizedBox(width: 12),
            const Text("Difficulty: Upto Medium", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white54)),
            const Spacer(),
            IconButton(
              icon: Icon(LucideIcons.settings, size: 18, color: isSelected ? Colors.white70 : Colors.white24),
              onPressed: isSelected
                  ? () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;
                      final updated = await showDialog<List<String>>(
                        context: context,
                        builder: (_) => ChapterSelectionPopup(
                          initiallySelected: selectedChapters,
                          classNum: 6,
                          subject: 'Math',
                          userId: user.uid,
                          onSave: (updatedChapters) {
                            Navigator.of(context).pop(updatedChapters);
                          },
                        ),
                      );
                      if (updated != null) {
                        onSettingsPressed(updated);
                      }
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}