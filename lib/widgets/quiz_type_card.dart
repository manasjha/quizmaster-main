import 'package:flutter/material.dart';

enum QuizTypeCardState { expanded, collapsed, locked }

class QuizTypeCard extends StatelessWidget {
  final QuizTypeCardState state;
  final bool isSelected;
  final VoidCallback? onSelect;
  final String title;
  final String subtitle;
  final Widget? expandedContent;

  const QuizTypeCard({
    super.key,
    required this.state,
    required this.isSelected,
    required this.onSelect,
    required this.title,
    required this.subtitle,
    this.expandedContent,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = state == QuizTypeCardState.locked;

    return GestureDetector(
      onTap: isLocked ? null : onSelect,
      child: Opacity(
        opacity: isLocked ? 0.4 : 1,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.greenAccent.withOpacity(0.08) : Colors.black,
            border: Border.all(
              color: isSelected ? Colors.greenAccent : Colors.grey.shade700,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isLocked ? Colors.white24 : Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isLocked)
                    const Icon(Icons.lock_outline, size: 16, color: Colors.white),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
              if (expandedContent != null) ...[
                const SizedBox(height: 12),
                expandedContent!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}