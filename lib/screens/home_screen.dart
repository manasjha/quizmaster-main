import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/header_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../providers/user_provider.dart';
import '../utils/auth_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          // TODO: Add actual home content here
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          // TODO: handle navigation between screens
        },
      ),
    );
  }
}