import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Classlecture extends StatefulWidget {
  final String classID;
  const Classlecture({super.key, required this.classID});

  @override
  State<Classlecture> createState() => _ClasslectureState();
}

class _ClasslectureState extends State<Classlecture> {
  // Store lecturer details
  final Map<String, Map<String, String>> lecturerCache = {};

  @override
  void initState() {
    super.initState();
    _fetchLecturers(); // Fetch lecturer data when the widget is initialized
  }

  // Fetch lecturerID / userID from the class document and then get their details
  Future<void> _fetchLecturers() async {
    try {
      final classDoc = await FirebaseFirestore.instance.collection('classes').doc(widget.classID).get();
      if (classDoc.exists) {
        final lecturerIDs = List<String>.from(classDoc['lecturer'] ?? []);
        _fetchLecturerDetails(lecturerIDs);
      }
    } catch (e) {
      print('Error fetching lecturers: $e');
    }
  }

  // Fetch lecturer details from the users collection
  Future<void> _fetchLecturerDetails(List<String> lecturerIDs) async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, whereIn: lecturerIDs).get();
      final userDocs = usersSnapshot.docs;

      setState(() {
        lecturerCache.clear(); // Clear previous data
        for (var doc in userDocs) {
          lecturerCache[doc.id] = {
            'username': doc['username'] ?? 'No Username',
            'email': doc['email'] ?? 'No Email',
            'contactnumber': doc['contactnumber'] ?? 'No Contact',
            'profile_img': doc['profile_img'] ?? '', // Assuming profile_img is stored as a URL
          };
        }
      });
    } catch (e) {
      print('Error fetching lecturer details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: lecturerCache.length, // Count the number of lecturers in the cache
      itemBuilder: (context, index) {
        final lecturerID = lecturerCache.keys.elementAt(index);
        final lecturerData = lecturerCache[lecturerID] ?? {};

        return Container(
          width: 90.w,
          padding: EdgeInsets.all(2.w),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: lecturerData['profile_img'] != ''
                    ? NetworkImage(lecturerData['profile_img']!)
                    : const AssetImage('images/profile.webp') as ImageProvider,
                radius: 7.w,
              ),
              SizedBox(width: 5.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 65.w,
                    child: Text(
                      lecturerData['username'] ?? 'No Username',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Roboto',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 65.w,
                    child: Text(
                      'Email: ${lecturerData['email'] ?? 'No Email'}',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontFamily: 'Roboto',
                        color: Colors.grey,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 65.w,
                    child: Text(
                      'Contact Number: ${lecturerData['contactnumber'] ?? 'No Contact'}',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontFamily: 'Roboto',
                        color: Colors.grey,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
