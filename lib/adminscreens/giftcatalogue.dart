import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/adminscreens/adminsubpage/addgift.dart';
import 'package:studybunnies/adminscreens/classes.dart';
import 'package:studybunnies/adminscreens/timetable.dart';
import 'package:studybunnies/adminwidgets/appbar.dart';
import 'package:studybunnies/adminwidgets/bottomnav.dart';
import 'package:studybunnies/adminwidgets/buildGiftsGridView.dart';
import 'package:studybunnies/adminwidgets/buildHistoryListView.dart';
import 'package:studybunnies/adminwidgets/drawer.dart';
import 'package:studybunnies/authentication/session.dart';

class Giftlist extends StatefulWidget {
  const Giftlist({super.key});

  @override
  State<Giftlist> createState() => _GiftlistState();
}

class _GiftlistState extends State<Giftlist> {
  final Session session = Session();
  String? userId;
  String? userName;
  String? profileImage;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }
  // get user data [username and profile image]
  Future<void> _fetchUserData() async {
    userId = await session.getUserId();
    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId!).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['username'];
          profileImage = userDoc['profileImage'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Swiping in right direction.
        if (details.delta.dx > 25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.leftToRight,
              duration: const Duration(milliseconds: 305),
              child: const Classlist(),
            ),
          );
        }
        // Swiping in left direction.
        if (details.delta.dx < -25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 305),
              child: const Timetablelist(),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: mainappbar(
          "Gift Catalogue",
          "This section includes the list of gifts that can be redeemed by the students.",
          context,
        ),
        drawer: const AdminDrawer(initialIndex: 4),
        bottomNavigationBar: navbar(4),
        body: Padding(
          padding: EdgeInsets.only(left: 3.w, right: 3.w, top: 0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 25.w, top: 2.h),
                child: ToggleButtons(
                  highlightColor: Colors.transparent,
                  textStyle: const TextStyle(fontFamily: 'Roboto'),
                  constraints: BoxConstraints(minWidth: 2.w, minHeight: 3.h),
                  isSelected: [selectedIndex == 0, selectedIndex == 1],
                  borderColor: Colors.transparent,
                  selectedBorderColor: Colors.transparent,
                  onPressed: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  selectedColor: Colors.black,
                  fillColor: Colors.transparent,
                  borderWidth: 0.0,
                  children: <Widget>[
                    buildToggleButton('Gifts', 0),
                    buildToggleButton('History', 1),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
              selectedIndex == 0 ? const GiftsGridView() : const HistoryListView(),
            ],
          ),
        ),
        floatingActionButton: selectedIndex == 0
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      duration: const Duration(milliseconds: 305),
                      child: const Addgift(),
                    ),
                  );
                },
                backgroundColor: const Color.fromARGB(255, 100, 30, 30),
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
      ),
    );
  }
  // in page navigation button
  Widget buildToggleButton(String text, int index) {
    Color bottomBorderColor =
        selectedIndex == index ? Colors.black : Colors.grey;

    return Container(
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
    );
  }
}
