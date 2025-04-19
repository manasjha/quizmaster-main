import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../screens/login_screen.dart';

Future<void> handleLogout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Provider.of<UserProvider>(context, listen: false).clearUser();

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}