import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/adminscreens/adminsubpage/adduser.dart';
import 'package:studybunnies/adminscreens/adminsubpage/edituser.dart';
import 'package:studybunnies/adminscreens/dashboard.dart';
import 'package:studybunnies/adminscreens/timetable.dart';
import 'package:studybunnies/adminwidgets/appbar.dart';
import 'package:studybunnies/adminwidgets/bottomnav.dart';
import 'package:studybunnies/adminwidgets/drawer.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/authentication/session.dart';

class Userlist extends StatefulWidget {
  const Userlist({super.key});

  @override
  State<Userlist> createState() => _UserlistState();
}

class _UserlistState extends State<Userlist> {
  final Session session = Session();
  String? userId;
  String? userName;
  String? profileImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }
  // get user data based on userID
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
  // save toggle button selected / activated
  List<bool> selectedFilters = [true, false, false, false];
  String searchQuery = '';
  String roleFilter = 'All';
  // check which toggle button or filter to be applied
  void focusButton(int index) {
    setState(() {
      for (int buttonIndex = 0; buttonIndex < selectedFilters.length; buttonIndex++) {
        selectedFilters[buttonIndex] = buttonIndex == index;
      }
      switch (index) {
        case 0:
          roleFilter = 'All';
          break;
        case 1:
          roleFilter = 'Student';
          break;
        case 2:
          roleFilter = 'Teacher';
          break;
        case 3:
          roleFilter = 'Admin';
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.leftToRight,
              duration: const Duration(milliseconds: 305),
              child: const Timetablelist(),
            ),
          );
        }
        if (details.delta.dx < -25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 305),
              child: const AdminDashboard(),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: mainappbar(
          "Users",
          "This page contains all information for the users registered in StudyBunnies",
          context,
        ),
        bottomNavigationBar: navbar(1),
        drawer: const AdminDrawer(initialIndex: 3),
        body: Padding(
          padding: EdgeInsets.only(left: 5.w, top: 1.5.h, right: 5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ToggleButtons(
                textStyle: const TextStyle(fontFamily: 'Roboto'),
                constraints: BoxConstraints(minWidth: 2.w, minHeight: 3.h),
                isSelected: selectedFilters,
                borderRadius: BorderRadius.circular(2.w),
                onPressed: focusButton,
                selectedColor: Colors.black,
                fillColor: Colors.grey,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Text(
                      'All',
                      style: TextStyle(
                        fontWeight: selectedFilters[0] ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Text(
                      'Students',
                      style: TextStyle(
                        fontWeight: selectedFilters[1] ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Text(
                      'Teachers',
                      style: TextStyle(
                        fontWeight: selectedFilters[2] ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Text(
                      'Admins',
                      style: TextStyle(
                        fontWeight: selectedFilters[3] ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Container(
                padding: EdgeInsets.all(1.w),
                width: 90.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 2.0.w),
                    const Icon(Icons.search),
                    SizedBox(width: 2.0.w),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Expanded( //get all user
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    // check user role
                    var users = snapshot.data!.docs.where((user) {
                      if (roleFilter != 'All' && user['role'] != roleFilter) {
                        return false;
                      }
                      if (searchQuery.isNotEmpty && !user['username'].toString().toLowerCase().contains(searchQuery.toLowerCase())) {
                        return false;
                      }
                      return true;
                    }).toList();
                    // sort user data in alphabetical order
                    users.sort((a, b) => a['username'].compareTo(b['username']));
                    // handling method if theres no record found
                    if (users.isEmpty) {
                      return Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('images/norecord.png'), 
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        var user = users[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(3.w),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeft,
                                duration: const Duration(milliseconds: 305),
                                child: Edituser(userID: user.id),
                              ),
                            );
                          },
                          child: Container(
                            width: 90.w,
                            padding: EdgeInsets.all(2.w),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: user['profile_img'] != "" && user['profile_img'] != null
                                      ? NetworkImage(user['profile_img'])
                                      : const AssetImage('images/profile.webp') as ImageProvider,
                                  radius: 7.w,
                                ),
                                SizedBox(width: 5.w),
                                SizedBox(
                                  width: 50.w,
                                  child: Text(
                                    user['username'],
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontFamily: 'Roboto',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.keyboard_arrow_right_outlined),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                duration: const Duration(milliseconds: 305),
                child: const Adduser(),
              ),
            );
          },
          backgroundColor: const Color.fromARGB(255, 100, 30, 30),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
