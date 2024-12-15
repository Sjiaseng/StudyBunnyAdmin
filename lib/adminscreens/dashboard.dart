import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybunnies/adminscreens/classes.dart';
import 'package:studybunnies/adminscreens/users.dart';
import 'package:studybunnies/adminscreens/adminsubpage/subfeedback.dart';
import 'package:studybunnies/adminwidgets/appbar.dart';
import 'package:studybunnies/adminwidgets/bottomnav.dart';
import 'package:studybunnies/adminwidgets/drawer.dart';
import 'package:studybunnies/adminwidgets/summarycontainer.dart';
import 'package:studybunnies/authentication/session.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final Session session = Session();
  
  String? userId;
  String? userName;
  String? profileImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _calculatetotaladmin();
    _calculatetotalclasses();
    _calculatetotalstudents();
    _calculatetotalteachers();
    _fetchUsernames();
  }
  // getting user data based on session ID stored
  Future<void> _fetchUserData() async {
    try {
      // Get the user ID from the session
      userId = await session.getUserId();
      if (userId == null) {
        print('User ID is null.');
        return;
      }

      // Fetch user document from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId!).get();
      if (!userDoc.exists) {
        print('User document does not exist.');
        return;
      }

      // Update state with fetched data
      setState(() {
        userName = userDoc.get('username');
        profileImage = userDoc.get('profile_img');
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }
  final Map<String, String> userCache = {};
  // get username based on userID
  Future<void> _fetchUsernames() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final userDocs = usersSnapshot.docs;

      setState(() {
        for (var doc in userDocs) {
          userCache[doc.id] = doc['username'] ?? 'No Username';
        }
      });
    } catch (e) {
      // Handle errors if needed
      print('Error fetching usernames: $e');
    }
  }

  String getUsername(String userId) {
    return userCache[userId] ?? 'No Username';
  }

  int? totalAdmin;
  int? totalTeacher;
  int? totalStudent;
  int? totalClass; 
  // calculate total number of admin in users doc
  Future<void> _calculatetotaladmin() async {
    try {
      final userCollection = FirebaseFirestore.instance.collection('users');
      final querySnapshot = await userCollection.where('role', isEqualTo: 'Admin').get();
      setState(() {
        totalAdmin = querySnapshot.size;
      });
      print('Total Admins: $totalAdmin');
    } catch (e) {
      print('Error calculating total admins: $e');
    }
  }
  // calculate total number of teacher in users doc
  Future<void> _calculatetotalteachers() async {
    try {
      final userCollection = FirebaseFirestore.instance.collection('users');
      final querySnapshot = await userCollection.where('role', isEqualTo: 'Teacher').get();
      setState(() {
        totalTeacher = querySnapshot.size;
      });
      print('Total Teachers: $totalTeacher');
    } catch (e) {
      print('Error calculating total teachers: $e');
    }
  }
 // calculate total number of student in users doc
  Future<void> _calculatetotalstudents() async {
    try {
      final userCollection = FirebaseFirestore.instance.collection('users');
      final querySnapshot = await userCollection.where('role', isEqualTo: 'Student').get();
      setState(() {
        totalStudent = querySnapshot.size;
      });
      print('Total Students: $totalStudent');
    } catch (e) {
      print('Error calculating total students: $e');
    }
  }
  // calculate total number of class in classes doc
  Future<void> _calculatetotalclasses() async {
    try {
      final classesCollection = FirebaseFirestore.instance.collection('classes');
      final querySnapshot = await classesCollection.get();
      setState(() {
        totalClass = querySnapshot.size;
      });
      print('Total Classes: $totalClass');
    } catch (e) {
      print('Error calculating total classes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarBrightness: Brightness.dark,
    ));

    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.leftToRight,
              duration: const Duration(milliseconds: 305),
              child: const Userlist(),
            ),
          );
        }
        if (details.delta.dx < -25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 305),
              child: const Classlist(),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: mainappbar("Home", "This is Admins' Dashboard.", context),
        bottomNavigationBar: navbar(2),
        drawer: const AdminDrawer(initialIndex: 0),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 7.w),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: profileImage != null && profileImage != ""
                          ? NetworkImage(profileImage!)
                          : const AssetImage('images/profile.webp'),
                      radius: 10.w,
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50.w,
                            child: Text(
                              userName ?? 'Myname',
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                                fontFamily: 'Roboto',
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 50.w,
                            child: Text(
                              userId != null ? 'Role: Administrator' : 'Role',
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontFamily: 'Roboto',
                                fontSize: 9.sp,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
              Padding(
                padding: EdgeInsets.only(left: 5.w),
                child: Text(
                  "Summary",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    fontSize: 15.sp,
                  ),
                ),
              ),
              SizedBox(height: 5.w),
              Padding(
                padding: EdgeInsets.only(left: 3.w, right: 2.w),
                child: Row(
                  children: [
                    SummaryContainer('Total Students', const Color.fromRGBO(217, 217, 217, 1), '$totalStudent'),
                    SizedBox(width: 5.w),
                    SummaryContainer('Total Teachers', const Color.fromRGBO(217, 217, 217, 1), '$totalTeacher'),
                  ],
                ),
              ),
              SizedBox(height: 4.w),
              Padding(
                padding: EdgeInsets.only(left: 3.w, right: 2.w),
                child: Row(
                  children: [
                    SummaryContainer('Total Admins', const Color.fromRGBO(217, 217, 217, 1), '$totalAdmin'),
                    SizedBox(width: 5.w),
                    SummaryContainer('Total Classes', const Color.fromRGBO(217, 217, 217, 1), '$totalClass'),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Padding(
                padding: EdgeInsets.only(left: 5.w),
                child: Text(
                  "Latest Feedback",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    fontSize: 15.sp,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              SizedBox(
                height: 26.2.h,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('feedback') // Ensure the collection name matches your Firestore structure
                      .orderBy('generation_date', descending: true) // Order by generation_date in descending order
                      .limit(10) // Limit to 10 documents
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final feedbackList = snapshot.data!.docs;

                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: feedbackList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final feedback = feedbackList[index];
                        final feedbackId = feedback.id;
                        final feedbackTitle = feedback['feedback_title'] ?? 'No Title';
                        final userId = feedback['userID'] ?? 'Unknown User';
                        final generationDate = feedback['generation_date']?.toDate() ?? DateTime.now();
                        final DateFormat formatter = DateFormat('(EEE) d/M/yyyy h:mm a'); // Format: Wed 12/6/2024 6:52 pm
                        final formattedDate = formatter.format(generationDate); 
                        final userName = getUsername(userId);

                        return Padding(
                          padding: EdgeInsets.only(left: 4.w, right: 4.w),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 1.5.h),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(3.w),
                              highlightColor: Colors.grey,
                              onTap: () {
                                Timer(const Duration(milliseconds: 205), () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      duration: const Duration(milliseconds: 305),
                                      child: Subfeedback(feedbackId: feedbackId), // Ensure you have the right page to navigate
                                    ),
                                  );
                                });
                              },
                              child: Container(
                                height: 15.h,
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color.fromRGBO(217, 217, 217, 1), width: 1.0),
                                  borderRadius: BorderRadius.circular(3.w),
                                  color: const Color.fromRGBO(217, 217, 217, 1),
                                ),
                                padding: EdgeInsets.only(left: 3.w, top: 1.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      feedbackTitle,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                        color: const Color.fromRGBO(116, 116, 116, 1),
                                      ),
                                    ),
                                    SizedBox(height: 2.w),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 12.sp,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          userName,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            overflow: TextOverflow.ellipsis,
                                            color: const Color.fromRGBO(116, 116, 116, 1),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 1.h),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          size: 12.sp,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          formattedDate,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            overflow: TextOverflow.ellipsis,
                                            color: const Color.fromRGBO(116, 116, 116, 1),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 3.w, top: 1.h),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          const Text(
                                            'View More',
                                            style: TextStyle(
                                              color: Color.fromRGBO(116, 116, 116, 1),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios_outlined,
                                            size: 10.sp,
                                            color: const Color.fromRGBO(116, 116, 116, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
      ),
    );
  }
}
