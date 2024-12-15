import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/adminscreens/adminsubpage/addclasslecture.dart';
import 'package:studybunnies/adminscreens/adminsubpage/addclassstudent.dart';
import 'package:studybunnies/adminscreens/adminsubpage/classlecture.dart';
import 'package:studybunnies/adminscreens/adminsubpage/classnote.dart';
import 'package:studybunnies/adminscreens/adminsubpage/classstudent.dart';
import 'package:studybunnies/adminscreens/adminsubpage/editclass.dart';
import 'package:studybunnies/adminwidgets/appbar.dart';
import 'package:studybunnies/adminwidgets/bottomnav.dart';
import 'package:studybunnies/adminwidgets/drawer.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/authentication/session.dart';

class Classinner extends StatefulWidget {
  final String classID;
  const Classinner({required this.classID, super.key});

  @override
  State<Classinner> createState() => _ClassinnerState();
}

class _ClassinnerState extends State<Classinner> {
  final Session session = Session();
  int selectedIndex = 0;
  String? className;

  // Correctly define userCache as Map<String, Map<String, String>>
  final Map<String, Map<String, String>> userCache = {};

  @override
  void initState() {
    super.initState();
    _fetchClassData();

  }
  // Get classname based on classID
  Future<void> _fetchClassData() async {
    final classDoc = await FirebaseFirestore.instance.collection('classes').doc(widget.classID).get();
    if (classDoc.exists) {
      setState(() {
        className = classDoc['classname'];
      });
    }
  }
  // Check index of toggle button
  void focusButton(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
  // Widget of Toggle Button for Interface Navigation in Same Page
  Widget buildToggleButton(String text, int index) {
    Color bottomBorderColor = selectedIndex == index ? Colors.black : Colors.grey;

    return GestureDetector(
      onTap: () => focusButton(index),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: bottomBorderColor, width: 2.0),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: selectedIndex == index
                  ? FontWeight.bold
                  : FontWeight.normal,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
  // Show which floating action button to be displayed based on the toggle button activated
  Widget buildFloatingActionButton() {
    switch (selectedIndex) {
      case 0:
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                duration: const Duration(milliseconds: 305),
                child: Editclass(classID: widget.classID),
              ),
            );
          },
          backgroundColor: const Color.fromARGB(255, 100, 30, 30),
          shape: const CircleBorder(),
          child: const Icon(Icons.edit, color: Colors.white),
        );
      case 1:
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                duration: const Duration(milliseconds: 305),
                child: Addclasslecture(classID: widget.classID),
              ),
            );
          },
          backgroundColor: const Color.fromARGB(255, 100, 30, 30),
          shape: const CircleBorder(),
          child: const Icon(Icons.person_add, color: Colors.white),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                duration: const Duration(milliseconds: 305),
                child: Addclassstudent(classID: widget.classID),
              ),
            );
          },
          backgroundColor: const Color.fromARGB(255, 100, 30, 30),
          shape: const CircleBorder(),
          child: const Icon(Icons.person_add, color: Colors.white),
        );
      default:
        return FloatingActionButton(
          onPressed: () {
            void showErrorDialog(String message) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Loading Failed'),
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
            showErrorDialog('Loading Please Wait...');
          },
          backgroundColor: const Color.fromARGB(255, 100, 30, 30),
          shape: const CircleBorder(),
          child: const Icon(Icons.edit, color: Colors.white),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: subappbar(className ?? "Class Name Here", context),
      bottomNavigationBar: navbar(3),
      drawer: const AdminDrawer(initialIndex: 3),
      body: Padding(
        padding: EdgeInsets.only(left: 5.w, top: 2.5.h, right: 5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildToggleButton('Notes', 0),
                buildToggleButton('Lecturer', 1),
                buildToggleButton('Student', 2),
              ],
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                children: [
                  Classnote(classID: widget.classID),
                  Classlecture(classID: widget.classID),
                  Classstudent(classID: widget.classID),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: buildFloatingActionButton(),
    );
  }
}
