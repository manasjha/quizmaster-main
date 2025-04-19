import 'package:flutter/material.dart';
import '../utils/auth_utils.dart';

class HeaderBar extends StatelessWidget {
  final String userPhotoUrl;

  const HeaderBar({super.key, required this.userPhotoUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Image.asset(
                    'assets/logo/isylsi_logo_new.png', // ✅ new logo path
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout') {
                      handleLogout(context);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ],
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(userPhotoUrl),
                    radius: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        // subtle separator
        Container(
          height: 0.5,
          color: Colors.white24,
        ),
      ],
    );
  }
}