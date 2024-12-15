import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/adminwidgets/top_snack_bar.dart';

class Subfeedback extends StatefulWidget {
  final String feedbackId;
  const Subfeedback({required this.feedbackId, super.key});

  @override
  State<Subfeedback> createState() => _SubfeedbackState();
}

class _SubfeedbackState extends State<Subfeedback> {
  String? feedbackDesc;
  String? feedbackTitle;
  DateTime? generationDate;
  String? userID;
  String? userRole;
  String? username;
  String? profileImage;
  String? formattedDate;

  @override
  void initState() {
    super.initState();
    _fetchFeedbackData();
  }
  // get feedback data based on feedbackID
Future<void> _fetchFeedbackData() async {
  try {
    final feedbackDoc = await FirebaseFirestore.instance.collection('feedback').doc(widget.feedbackId).get();
    if (feedbackDoc.exists) {
      final data = feedbackDoc.data()!;
      setState(() {
        feedbackDesc = data['feedback_desc'];
        feedbackTitle = data['feedback_title'];
        generationDate = (data['generation_date'] as Timestamp).toDate();
        userID = data['userID'];
        userRole = data['user_role'];

        // Format the date and assign it to the formattedDate variable
        final DateFormat formatter = DateFormat('(EEE) d/M/yyyy h:mm a'); // Format: Wed 12/6/2024 6:52 pm
        formattedDate = formatter.format(generationDate!); // formattedDate should be a String
      });
      
      if (userID != null) {
        _fetchUserData(userID!);
      }
    }
  } catch (e) {
    print('Error fetching feedback data: $e');
  }
}
    // delete feedback based on the feedbackID
  Future<void> _deleteFeedback() async {
    try {
      await FirebaseFirestore.instance.collection('feedback').doc(widget.feedbackId).delete();
      Navigator.pop(context);
      showTopSnackBar(
          context,
          'Successfully Deleted!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
      );
    } catch (e) {
      print('Error deleting feedback: $e');
      showTopSnackBar(
        context,
        'Error in Deletion!',
        backgroundColor: const Color.fromARGB(255, 246, 77, 65),
        textColor: Colors.white,
      );
    }
  }
  // get user data though userID
  Future<void> _fetchUserData(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          username = data['username'];
          profileImage = data['profile_img'];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: 7.w, top: 3.h),
                    width: 10.w,
                    height: 10.h,
                    child: Icon(Icons.arrow_back, size: 20.sp),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(top: 3.h, right: 8.w),
                      child: Text(
                        'View Feedback',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                children: [
                  Container(
                    height: 70.h, 
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(217, 217, 217, 1),
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(3.w),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 3.w, top: 0.h),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: profileImage != null
                                            ? NetworkImage(profileImage!)
                                            : const AssetImage('images/profile.webp') as ImageProvider,
                                        radius: 7.w,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 3.w),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(top: 1.h),
                                              width: 50.w,
                                              child: Text(
                                                username ?? 'Username',
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10.sp,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 0.5.h), // Push the role text down slightly
                                              child: Text(
                                                'Role: ${userRole ?? 'Role'}',
                                                textAlign: TextAlign.left,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10.sp,
                                                  overflow: TextOverflow.fade,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  feedbackTitle ?? 'Feedback Title Goes Here...',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  feedbackDesc ?? 'Feedback Content Goes Here',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 3.w,
                          bottom: 1.h,
                          child: Text(
                            'Date: $formattedDate',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.h),
                  ElevatedButton(
                    onPressed: () {
                      _deleteFeedback();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.red, width: 2), // Add border here
                      ),
                      minimumSize: const Size(double.infinity, 50), // Ensures the button takes full width
                    ),
                    child: const Text(
                      'Delete Feedback',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
