import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studybunnies/authentication/loginscreen.dart';
import 'package:studybunnies/authentication/session.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarBrightness: Brightness.dark,
  ));

  final Session session = Session();
  final String? userId = await session.getUserId();
  runApp(MyApp(isLoggedIn: userId != null && userId.isNotEmpty));
}

ThemeData theme() {
  return ThemeData(
    textTheme: GoogleFonts.robotoTextTheme(),
    scaffoldBackgroundColor: const Color.fromRGBO(239, 238, 233, 1),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme(),
          home: const Loginscreen(),
        );
      },
    );
  }
}

