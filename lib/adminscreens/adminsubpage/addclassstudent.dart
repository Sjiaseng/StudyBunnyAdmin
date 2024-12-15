import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sizer/sizer.dart';

class Addclassstudent extends StatefulWidget {
  final String classID;
  const Addclassstudent({super.key, required this.classID});

  @override
  State<Addclassstudent> createState() => _AddclassstudentState();
}

class _AddclassstudentState extends State<Addclassstudent> {
  TextEditingController mycontroller = TextEditingController();
  String searchQuery = '';
  final _formKey = GlobalKey<FormState>();

  // State variable to manage checkbox values
  final Map<String, bool> _selectedStudents = {};

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      // Fetch list of student IDs from the class document
      final classDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classID)
          .get();

      if (classDoc.exists) {
        final students = classDoc.data()?['student'] as List<dynamic>? ?? [];
        // Fetch all users with the role 'Student'
        final userDocs = await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Student')
            .get();

        final studentsMap = <String, bool>{};
        for (var doc in userDocs.docs) {
          final studentID = doc['userID'] as String? ?? '';
          if (students.contains(studentID)) {
            studentsMap[studentID] = true;
          } else {
            studentsMap[studentID] = false;
          }
        }

        setState(() {
          _selectedStudents.addAll(studentsMap);
        });
      }
    } catch (e) {
      print('Error fetching students: $e');
    }
  }
  // Update Student Records
  Future<void> _updateStudents() async {
    try {
      final selectedStudentIDs = _selectedStudents.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classID)
          .update({'student': selectedStudentIDs});
    } catch (e) {
      print('Error updating students: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                          'Adding Student',
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
              Padding(
                padding: EdgeInsets.only(left: 5.5.w, top: 1.h),
                child: Container(
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
                              searchQuery = value.toLowerCase();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 65.h,
                padding: EdgeInsets.only(left: 5.5.w, right: 5.5.w),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users') // Your Firestore collection name
                      .where('role', isEqualTo: 'Student')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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

                    final docs = snapshot.data!.docs.where((doc) {
                      final name = doc['username']?.toLowerCase() ?? '';
                      return name.contains(searchQuery);
                    }).toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final name = doc['username'] ?? 'No Name';
                        final id = doc['userID'] ?? 'No ID';
                        final img = doc['profile_img'] ?? 'images/profile.webp';

                        return Container(
                          width: 90.w,
                          padding: EdgeInsets.all(2.w),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: img.isNotEmpty
                                    ? NetworkImage(img)
                                    : const AssetImage('images/profile.webp') as ImageProvider,
                                radius: 7.w,
                              ),
                              SizedBox(width: 5.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 50.w,
                                    child: Text(
                                      name,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontFamily: 'Roboto',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50.w,
                                    child: Text(
                                      'ID: $id',
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
                              Checkbox(
                                value: _selectedStudents[id] ?? false,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _selectedStudents[id] = value ?? false;
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 5.5.h),
              Padding(
                padding: EdgeInsets.only(left: 5.5.w, right: 5.5.w),
                child: ElevatedButton(
                  onPressed: () async {
                    await _updateStudents();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Add Student',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
