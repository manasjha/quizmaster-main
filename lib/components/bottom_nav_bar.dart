import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        iconTheme: const IconThemeData(size: 16, color: Colors.white54),
        textTheme: Theme.of(context).textTheme.copyWith(
              bodySmall: const TextStyle(fontSize: 8, color: Colors.white54),
            ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white24, width: 0.25),
          ),
        ),
        padding: const EdgeInsets.only(bottom: 2, top: 2),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          iconSize: 16,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Transform.translate(
                offset: const Offset(0, -4),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE62E53),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.play,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              label: ' ',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.lightbulb),
              label: 'Insights',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 18,
                width: 18,
                child: Image.asset(
                  'assets/icons/leaf_icon_gray.png',
                  fit: BoxFit.contain,
                ),
              ),
              label: 'Syl',
            ),
          ],
        ),
      ),
    );
  }
}