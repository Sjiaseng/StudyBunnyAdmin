import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/adminwidgets/top_snack_bar.dart';

class Addclasslecture extends StatefulWidget {
  final String classID;
  const Addclasslecture({super.key, required this.classID});

  @override
  State<Addclasslecture> createState() => _AddclasslectureState();
}

class _AddclasslectureState extends State<Addclasslecture> {
  TextEditingController mycontroller = TextEditingController();
  String searchQuery = '';
  final _formKey = GlobalKey<FormState>();

  // State variable to manage checkbox values
  final Map<String, bool> _selectedLecturers = {};

  @override
  void initState() {
    super.initState();
    _loadLecturers();
  }

  Future<void> _loadLecturers() async {
    // Retrieve the list of lecturer IDs from the class document
    try {
      final classDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classID)
          .get();

      if (classDoc.exists) {
        final lecturers = classDoc.data()?['lecturer'] as List<dynamic>? ?? [];
        setState(() {
          for (var lecturerID in lecturers) {
            _selectedLecturers[lecturerID] = true;
          }
        });
      }
    } catch (e) {
      print('Error fetching lecturers: $e');
    }
  }

  // Adding Lecturer into Class
  Future<void> _updateLecturers() async {
    final selectedLecturers = _selectedLecturers.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    try {
      // Update Lecturer Array into classes doc based on classID
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classID)
          .update({
        'lecturer': selectedLecturers,
      });

      showTopSnackBar(
        context,
        'Successfully Updated Lecturer List !',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

    } catch (e) {
      print('Error updating lecturers: $e');
      showTopSnackBar(
        context,
        'Fail to Update Lecturer List !',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

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
                          'Adding Lecturer',
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
                      .where('role', isEqualTo: 'Teacher')
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
                                value: _selectedLecturers[id] ?? false,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _selectedLecturers[id] = value ?? false;
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
                  onPressed: _updateLecturers, // Updated function call
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Add Lecturer',
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
