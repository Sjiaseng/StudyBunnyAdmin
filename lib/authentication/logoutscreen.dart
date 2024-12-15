import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studybunnies/authentication/loginscreen.dart';
import 'session.dart'; 

class Logoutscreen extends StatefulWidget {

  const Logoutscreen({super.key});

  @override
  State<Logoutscreen> createState() => _LogoutscreenState();
}

class _LogoutscreenState extends State<Logoutscreen> {
  final List<String> texts = [
    'Logging out, please wait...',
    'Heading to Login page...',
    'Goodbye...',
  ];

  int _currentTextIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _logoutAndNavigate();
  }

  Future<void> _logoutAndNavigate() async {
    // Clear session and log out from Firebase Auth
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // Handle errors if any
      print('Error logging out: $e');
    }

    // Clear local session data using your Session class
    final session = Session();
    try {
      await session.clearSession();
        String? userIdAfterClear = await session.getUserId();
        print('Session after clearing: userId = $userIdAfterClear');

    } catch (e) {
      // Handle errors if any
      print('Error clearing session data: $e');
    }

    // Navigate to the login screen
    Future.delayed(const Duration(seconds: 8), () {
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 500),
          child: const Loginscreen(),
        ),
      );
    });
  }
  // timer to change the texts
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      setState(() {
        _currentTextIndex = (_currentTextIndex + 1) % texts.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 222, 179, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'appicon/transparent_logo.png',
              width: 45.w,
              height: 30.h,
            ),
            Image.asset(
              'images/loading.gif', 
              width: 17.w,
              height: 17.h,
            ),
            const SizedBox(height: 20),
            Text(
              texts[_currentTextIndex],
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(184, 89, 30, 1.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
