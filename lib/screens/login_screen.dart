import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';
import 'ftue_screen.dart';
import 'logo_block.dart';
import 'logo_wrapper.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool isSigningIn = false;

  late AnimationController _logoShiftController;
  late AnimationController _ctaFadeController;
  late Animation<double> _ctaFade;

  @override
  void initState() {
    super.initState();

    _logoShiftController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    _ctaFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _ctaFade = CurvedAnimation(
      parent: _ctaFadeController,
      curve: Curves.easeIn,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _ctaFadeController.forward();
    });
  }

  @override
  void dispose() {
    _logoShiftController.dispose();
    _ctaFadeController.dispose();
    super.dispose();
  }

  Future<void> signInWithGoogle() async {
    setState(() => isSigningIn = true);

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => isSigningIn = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCred.user;

      if (user != null) {
        final userModel = UserModel(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          photoUrl: user.photoURL ?? '',
        );

        // Store user in Provider
        Provider.of<UserProvider>(context, listen: false).setUser(userModel);

        final userDocRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final userDoc = await userDocRef.get();

        if (userDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          await userDocRef.set({
            'uid': user.uid,
            'name': user.displayName,
            'email': user.email,
            'photoUrl': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FTUEScreen()),
          );
        }
      }
    } catch (e) {
      print('❌ SIGN IN ERROR: $e');
    } finally {
      setState(() => isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _logoShiftController,
              builder: (_, __) {
                final offsetY = -6 * _logoShiftController.value;
                return LogoWrapper(offsetY: offsetY);
              },
            ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _ctaFade,
                child: Center(
                  child: OutlinedButton.icon(
                    onPressed: isSigningIn ? null : signInWithGoogle,
                    icon: isSigningIn
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.login, color: Color(0xFFE62E53)),
                    label: Text(
                      isSigningIn ? 'Signing in...' : 'Continue with Google',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE62E53), width: 1.5),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}