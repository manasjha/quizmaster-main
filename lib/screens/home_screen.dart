import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/header_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../providers/user_provider.dart';
import '../utils/auth_utils.dart';
import 'history_screen.dart';
import 'insights_screen.dart';
import 'syl_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Center(child: Text('Home Screen')),
    const HistoryScreen(),
    const SizedBox(), // Placeholder for Play tab
    const InsightsScreen(),
    const SylScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
                handleLogout(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          HeaderBar(userPhotoUrl: user?.photoUrl ?? ''),
          Expanded(
            child: _screens[_currentIndex == 2 ? 0 : _currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            // Launch quiz flow logic later
            return;
          }
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}