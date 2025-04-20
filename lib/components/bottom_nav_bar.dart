import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizmaster/widgets/quiz_start_popup.dart'; // <- NEW
import 'package:quizmaster/services/fetch_user_quiz_setup.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = screenWidth / 5;
    const highlightColor = Color(0xFFE62E53);
    const separatorColor = Colors.white24;

    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        iconTheme: const IconThemeData(size: 14, color: Colors.white54),
        textTheme: Theme.of(context).textTheme.copyWith(
              bodySmall: const TextStyle(fontSize: 8, color: Colors.white),
            ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            selectedFontSize: 0,
            unselectedFontSize: 0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.home,
                        color: currentIndex == 0 ? highlightColor : Colors.white54,
                      ),
                      const SizedBox(height: 6),
                      Text('Home', style: TextStyle(fontSize: 12, color: Colors.white54)),
                    ],
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.history,
                        color: currentIndex == 1 ? highlightColor : Colors.white54,
                      ),
                      const SizedBox(height: 6),
                      Text('History', style: TextStyle(fontSize: 12, color: Colors.white54)),
                    ],
                  ),
                ),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: SizedBox.shrink(),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.lightbulb,
                        color: currentIndex == 3 ? highlightColor : Colors.white54,
                      ),
                      const SizedBox(height: 6),
                      Text('Insights', style: TextStyle(fontSize: 12, color: Colors.white54)),
                    ],
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.leaf,
                        color: currentIndex == 4 ? highlightColor : Colors.white54,
                      ),
                      const SizedBox(height: 6),
                      Text('Syl', style: TextStyle(fontSize: 12, color: Colors.white54)),
                    ],
                  ),
                ),
                label: '',
              ),
            ],
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(height: 0.5, color: separatorColor),
          ),

          Positioned(
            top: 0,
            left: tabWidth * currentIndex,
            child: Container(width: tabWidth, height: 1.5, color: highlightColor),
          ),

          // Center Play Button
          Positioned(
            top: -10,
            left: (screenWidth - 60) / 2,
            child: Material(
              elevation: 6,
              shape: const CircleBorder(),
              color: highlightColor,
              child: InkWell(
                onTap: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  final result = await fetchUserQuizSetup(
                    userId: user.uid,
                    classNum: 6,
                    subject: 'Math',
                  );

                  showDialog(
                    context: context,
                    builder: (_) => QuizStartPopup(
                      quizzesAttempted: result.quizzesAttempted,
                      aiQuizzesAvailable: result.aiQuizzesAvailable,
                      selectedChapters: result.selectedChapters,
                    ),
  );
},

                customBorder: const CircleBorder(),
                child: const SizedBox(
                  height: 60,
                  width: 60,
                  child: Icon(
                    LucideIcons.play,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}