import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/adminscreens/adminsubpage/subfeedback.dart';
import 'package:studybunnies/adminwidgets/appbar.dart';
import 'package:studybunnies/adminwidgets/bottomnav.dart';
import 'package:studybunnies/adminwidgets/drawer.dart';
import 'package:studybunnies/authentication/session.dart';

class Feedbacklist extends StatefulWidget {
  const Feedbacklist({super.key});

  @override
  State<Feedbacklist> createState() => _FeedbacklistState();
}

class _FeedbacklistState extends State<Feedbacklist> {
  final Session session = Session();
  String? userId;
  String? userName;
  String? profileImage;
  // check which toggle button is activated
  List<bool> selectedFilters = [true, false];
  TextEditingController mycontroller = TextEditingController();
  String searchQuery = '';

  // Map to cache usernames
  final Map<String, String> userCache = {};
  final Map<String, String> profileImageCache = {}; 

  @override
  void initState() {
    super.initState();
    _fetchUsernames();
    _fetchProfileImages();  // Added call to fetch profile images
  }

  // Fetch and cache usernames
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

  // Fetch and cache profile images
  Future<void> _fetchProfileImages() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final userDocs = usersSnapshot.docs;

      setState(() {
        for (var doc in userDocs) {
          final data = doc.data();
          final profileImage = data['profile_img'] is String ? data['profile_img'] as String : '';
          profileImageCache[doc.id] = profileImage;
        }
      });
    } catch (e) {
      print('Error fetching profile images: $e');
    }
  }

  String getUsername(String userId) {
    return userCache[userId] ?? 'No Username';
  }

  String getProfileImage(String userId) {
    return profileImageCache[userId] ?? '';
  }
  // check which filter / toggle button activated
  void focusButton(int index) {
    setState(() {
      for (int i = 0; i < selectedFilters.length; i++) {
        selectedFilters[i] = i == index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainappbar(
        "Feedback",
        "This section consists of feedback retrieved from teachers and students.",
        context
      ),
      drawer: const AdminDrawer(initialIndex: 5),
      bottomNavigationBar: inactivenavbar(),
      body: Padding(
        padding: EdgeInsets.fromLTRB(5.w, 1.5.h, 5.w, 0),
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
                    'Latest',
                    style: TextStyle(
                      fontWeight: selectedFilters[0] ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Text(
                    'Oldest',
                    style: TextStyle(
                      fontWeight: selectedFilters[1] ? FontWeight.bold : FontWeight.normal,
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
                      controller: mycontroller,
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
            Expanded(
              child: StreamBuilder<QuerySnapshot>( // get and display feedback data
                stream: FirebaseFirestore.instance.collection('feedback').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var feedbacks = snapshot.data!.docs.where((feedback) {
                    if (searchQuery.isNotEmpty && !feedback['feedback_desc'].toString().toLowerCase().contains(searchQuery.toLowerCase())) {
                      return false;
                    }
                    return true;
                  }).toList();

                  if (feedbacks.isEmpty) {
                    return Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('images/norecord.png'),
                          Text('No feedback available', style: TextStyle(fontSize: 16.sp)),
                        ],
                      ),
                    );
                  }
                  // based on selected filter, align the data based on generated time in ascending/descending form
                  feedbacks.sort((a, b) {
                    // Example sort logic, adjust based on the selected filter
                    return selectedFilters[0]
                        ? (b['generation_date'] as Timestamp).compareTo(a['generation_date'] as Timestamp)
                        : (a['generation_date'] as Timestamp).compareTo(b['generation_date'] as Timestamp);
                  });

                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: feedbacks.length,
                    itemBuilder: (BuildContext context, int index) {
                      final feedback = feedbacks[index];
                      final feedbackDate = (feedback['generation_date'] as Timestamp).toDate();
                      final userId = feedback['userID'] ?? 'No UserID';
                      final username = getUsername(userId);
                      final profileImageUrl = getProfileImage(userId);
                      final feedbackId = feedback.id;
                      final DateFormat formatter = DateFormat('(EEE) d/M/yyyy h:mm a'); // Format: Wed 12/6/2024 6:52 pm
                      final formattedDate = formatter.format(feedbackDate); 

                      return Container(
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
                                  child:Subfeedback(feedbackId: feedbackId),
                                ),
                              );
                            });
                          },
                          child: Container(
                            height: 17.h,
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color.fromRGBO(217, 217, 217, 1), width: 1.0),
                              borderRadius: BorderRadius.circular(3.w),
                              color: const Color.fromRGBO(217, 217, 217, 1),
                            ),
                            padding: EdgeInsets.only(left: 3.w, top: 1.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 2.w),
                                    child: Text(formattedDate),
                                  ),
                                ),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 3.8.w,
                                      backgroundColor: Colors.grey,
                                      backgroundImage: profileImageUrl.isNotEmpty && profileImageUrl != ""
                                          ? NetworkImage(profileImageUrl)
                                          : const AssetImage('images/profile.webp') as ImageProvider,
                                    ),
                                    SizedBox(width: 3.w),
                                    SizedBox(
                                      width: 72.w,
                                      child: Text(
                                        username,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp,
                                          color: Colors.black,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.h),
                                SizedBox(
                                  width: 82.w,
                                  height: 3.h,
                                  child: Text(
                                    feedback['feedback_title'] ??
                                    'No Title',
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.black,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 85.w,
                                  height: 5.h,
                                  child: Text(
                                    feedback['feedback_desc'] ?? 
                                    'No Description',
                                    maxLines: 2,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.black,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ),
                              ],
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
    );
  }
}
