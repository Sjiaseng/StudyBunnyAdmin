import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Forgetpassword extends StatefulWidget {
  const Forgetpassword({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ForgetpasswordState createState() => _ForgetpasswordState();
}

class _ForgetpasswordState extends State<Forgetpassword> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      String email = _emailController.text;

      try {
        // Check if email exists in Firebase Authentication
        List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email);

        if (signInMethods.isEmpty) {
          // Email not found in Firebase Authentication, check Firestore if needed
          QuerySnapshot userQuery = await _firestore.collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

          if (userQuery.docs.isEmpty) {
            _showErrorDialog('No records found for this email address.');
            return;
          }
        }

        // Send password reset email
        await _auth.sendPasswordResetEmail(email: email);

        // Update Firestore to reflect password reset request
        DocumentSnapshot userSnapshot = await _firestore.collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get()
            .then((snapshot) => snapshot.docs.first);

        if (userSnapshot.exists) {
          DocumentReference userDoc = _firestore.collection('users').doc(userSnapshot.id);
          await userDoc.update({
            'passwordResetRequested': true,
            'resetRequestedAt': Timestamp.now(),
          });
        }

        _showSuccessDialog('Password Reset Email Sent Successfully, Please Check your Email for further Operation ! ');

      } catch (e) {
        _showErrorDialog('Failed to reset password: $e');
        print('Error resetting password: $e');
      }
    }
  }
  // widgets to show dialog box based on the status
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context); // Optionally pop back to the previous screen
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
                    "Forget Password",
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
                            return 'Please enter an email address';
                          } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[cC][oO][mM]$').hasMatch(value)) {
                            return 'Please enter a valid email address ending with .com';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20.h,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(double.infinity, 7.h),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(195, 154, 28, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10.h,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
              child: ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(double.infinity, 7.h),
                ),
                child: const Text(
                  'Reset Password',
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
