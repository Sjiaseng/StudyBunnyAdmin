import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/adminscreens/adminsubpage/classcomment.dart';
import 'dart:async';

class Classnote extends StatefulWidget {
  final String classID;
  const Classnote({super.key, required this.classID});

  @override
  State<Classnote> createState() => _ClassnoteState();
}

class _ClassnoteState extends State<Classnote> {
  final Map<String, Map<String, String>> userCache = {};

  @override
  void initState() {
    super.initState();
    _fetchUsernames(); 
    _fetchUserProfileImages();  
  }
  // Get Username based on UserID
  Future<void> _fetchUsernames() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final userDocs = usersSnapshot.docs;

      setState(() {
        for (var doc in userDocs) {
          userCache[doc.id] = {
            'username': doc['username'] ?? 'No Username',
            'profile_img': userCache[doc.id]?['profile_img'] ?? '' // Ensure profile_img is present if already cached
          };
        }
      });
    } catch (e) {
      print('Error fetching usernames: $e');
    }
  }
  // Get profile image based on UserID
  Future<void> _fetchUserProfileImages() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final userDocs = usersSnapshot.docs;

      setState(() {
        for (var doc in userDocs) {
          if (userCache.containsKey(doc.id)) {
            userCache[doc.id]!['profile_img'] = doc['profile_img'] ?? ''; // Update profile_img in the cache
          }
        }
      });
    } catch (e) {
      print('Error fetching user profile images: $e');
    }
  }

  String getUsername(String teacherId) {
    return userCache[teacherId]?['username'] ?? 'No Username';
  }

  String getUserProfileImage(String teacherId) {
    return userCache[teacherId]?['profile_img'] ?? ''; 
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance // get class notes data based on classID
          .collection('notes')
          .where('classID', isEqualTo: widget.classID)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Extract and sort notes
        var notes = snapshot.data!.docs;
        notes.sort((a, b) {
          var dateA = (a['postedDate'] as Timestamp).toDate();
          var dateB = (b['postedDate'] as Timestamp).toDate();
          return dateB.compareTo(dateA); // Sort descending
        });

        return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: notes.length,
          itemBuilder: (BuildContext context, int index) {
            var noteData = notes[index];
            var noteID = noteData['noteID'];
            var noteTitle = noteData['noteTitle'];
            var postedDate = noteData['postedDate'].toDate();
            var formattedDate =
                '${postedDate.month}/${postedDate.day}/${postedDate.year} ${postedDate.hour}:${postedDate.minute}:${postedDate.second}';
            var teacherID = noteData['teacherID'];
            var lecturerName = getUsername(teacherID);
            var profileImage = getUserProfileImage(teacherID);

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
                          child: Classcomment(noteID: noteID),
                        ),
                      );
                    });
                  },
                  child: Container(
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.only(top: 0.5.h, right: 2.w),
                            child: Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 5.w),
                              child: CircleAvatar(
                                backgroundImage: profileImage.isNotEmpty
                                    ? NetworkImage(profileImage)
                                    : const AssetImage('images/profile.webp') as ImageProvider,
                                radius: 8.w,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 50.w,
                                  height: 3.h,
                                  padding: EdgeInsets.only(left: 2.w, bottom: 0.h),
                                  child: Text(
                                    lecturerName, 
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 50.w,
                                  padding: EdgeInsets.only(left: 2.w),
                                  child: Text(
                                    'Note Title: $noteTitle',
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.grey,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 1.h)
                              ],
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            Positioned(
                              child: Padding(
                              padding: EdgeInsets.only(top: 0.5.h, right: 0.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'View Comments',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 1.w),
                                    child: Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      size: 8.sp,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                ],
                              ),
                              ),
                            ),
                          ],
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
    );
  }
}
