import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/adminscreens/dashboard.dart';
import 'package:studybunnies/studentscreens/dashboard.dart';
import 'package:studybunnies/teacherscreens/dashboard.dart';

class Splashscreen extends StatefulWidget {
  final String userrole;
  const Splashscreen({required this.userrole, super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final List<String> texts = [
    'Loading, please wait...',
    'Welcome to StudyBunnies!',
    'Getting things ready...',
  ];

  int _currentTextIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    routing(); 
  }

  void routing() {
    Future.delayed(const Duration(seconds: 8), () {
      Widget targetPage;

      switch (widget.userrole) { 
        case 'Admin':
          targetPage = const AdminDashboard();
          break;
        case 'Teacher':
          targetPage = const TeacherDashboard();
          break;
        case 'Student':
          targetPage = const StudentDashboard();
          break;
        default:
          targetPage = const AdminDashboard(); 
          break;
      }

      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 500),
          child: targetPage,
        ),
      );
    });
  }

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
