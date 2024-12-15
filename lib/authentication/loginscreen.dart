import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/authentication/forgetpassword.dart';
import 'package:studybunnies/authentication/splashscreen.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginscreenState createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Attempt to sign in with email and password
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        User? user = userCredential.user;

        if (user != null) {
          // Retrieve the user document from Firestore
          DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
          
          // Ensure the document exists
          if (!userDoc.exists) {
            _showErrorDialog('User document not found!');
            return;
          }

          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
          String role = data?['role']?.toString() ?? 'Unknown'; 
          
          
          String? storedPasswordHash = data?['password']; 

          
          if (_passwordController.text != storedPasswordHash) {
            // Update password using Firebase Authentication
            await user.updatePassword(_passwordController.text);
            
            
            await _firestore.collection('users').doc(user.uid).update({
              'password': _passwordController.text, 
            });
          }

          await _secureStorage.write(key: 'userID', value: user.uid);
          await _secureStorage.write(key: 'userEmail', value: user.email!);

          String? userId = await _secureStorage.read(key: 'userID');
          print('Retrieved User ID: $userId');
          print('User Role: $role');
          
          // Navigate to the appropriate dashboard based on user role
          if (role == 'Admin' && mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Splashscreen(userrole: role)));
          } else if (role == 'Teacher' && mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Splashscreen(userrole: role)));
          } else if (role == 'Student' && mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Splashscreen(userrole: role)));
          } else {
            _showErrorDialog('Your Record has Been Deleted !');
          }
        }
      } catch (e) {
        _showErrorDialog('Invalid Credentials Please Retry!');
        print('Error signing in: $e'); 
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 7.h),
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      fontSize: 18.sp,
                      color: const Color.fromRGBO(100, 30, 30, 1),
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'E-mail',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter an Email Address';
                          } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[cC][oO][mM]$').hasMatch(value)) {
                            return 'Please Enter a Valid Email Address ending with .com';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 4.h),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              size: 17.sp,
                              color: Colors.grey,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                        obscureText: _obscurePassword,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context, 
                                PageTransition(
                                  type: PageTransitionType.topToBottom,
                                  duration: const Duration(milliseconds: 305),
                                  child: const Forgetpassword(),
                                )
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ).copyWith(
                              overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: const Color.fromRGBO(100, 30, 30, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10.h,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
              child: ElevatedButton(
                onPressed: _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(double.infinity, 7.h),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(195, 154, 28, 1),
                    fontWeight: FontWeight.bold,
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
