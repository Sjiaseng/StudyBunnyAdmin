import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Classstudent extends StatefulWidget {
  final String classID;
  const Classstudent({super.key, required this.classID});

  @override
  State<Classstudent> createState() => _ClassstudentState();
}

class _ClassstudentState extends State<Classstudent> {
  // Store student details
  final Map<String, Map<String, String>> studentCache = {};

  @override
  void initState() {
    super.initState();
    _fetchStudents(); // Fetch student data when the widget is initialized
  }

  // Fetch student IDs from the class document and then get their details
  Future<void> _fetchStudents() async {
    try {
      final classDoc = await FirebaseFirestore.instance.collection('classes').doc(widget.classID).get();
      if (classDoc.exists) {
        final studentIDs = List<String>.from(classDoc['student'] ?? []);
        _fetchStudentDetails(studentIDs);
      }
    } catch (e) {
      print('Error fetching students: $e');
    }
  }

  // Fetch student details from the users collection
  Future<void> _fetchStudentDetails(List<String> studentIDs) async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, whereIn: studentIDs).get();
      final userDocs = usersSnapshot.docs;

      setState(() {
        studentCache.clear(); // Clear previous data
        for (var doc in userDocs) {
          studentCache[doc.id] = { // get information based on userID
            'username': doc['username'] ?? 'No Username',
            'email': doc['email'] ?? 'No Email',
            'contactnumber': doc['contactnumber'] ?? 'No Contact',
            'profile_img': doc['profile_img'] ?? '', // Assuming profile_img is stored as a URL
          };
        }
      });
    } catch (e) {
      print('Error fetching student details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: studentCache.length, // Count the number of students in the cache
      itemBuilder: (context, index) {
        final studentID = studentCache.keys.elementAt(index);
        final studentData = studentCache[studentID] ?? {};

        return Container(
          width: 90.w,
          padding: EdgeInsets.all(2.w),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: studentData['profile_img'] != ''
                    ? NetworkImage(studentData['profile_img']!)
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
                      studentData['username'] ?? 'No Username',
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
                      'Email: ${studentData['email'] ?? 'No Email'}',
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
                      'Contact Number: ${studentData['contactnumber'] ?? 'No Contact'}',
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
