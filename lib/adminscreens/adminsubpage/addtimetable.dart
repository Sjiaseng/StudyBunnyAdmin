import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:studybunnies/adminwidgets/top_snack_bar.dart';

class Addtimetable extends StatefulWidget {
  const Addtimetable({super.key});

  @override
  State<Addtimetable> createState() => _AddtimetableState();
}

class _AddtimetableState extends State<Addtimetable> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedClass;
  String? _selectedLecturer;
  String? _selectedDuration;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Future<List<Map<String, dynamic>>>? _classOptions;
  Future<List<Map<String, dynamic>>>? _lecturerOptions;

  final _courseNameController = TextEditingController();
  final _venueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _classOptions = _fetchClasses();
    _lecturerOptions = _fetchLecturers();
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _venueController.dispose();
    super.dispose();
  }
  // Map classID with classname
  Future<List<Map<String, dynamic>>> _fetchClasses() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('classes').get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc.data()['classname'] ?? 'Unknown Class',
      };
    }).toList();
  }
  // Map UserID (Teacher Role) with their username 
  Future<List<Map<String, dynamic>>> _fetchLecturers() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'Teacher').get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc.data()['username'] ?? 'Unknown Lecturer',
      };
    }).toList();
  }
  // Range of Date to Display
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  // Show Time Picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  // Save / Add new timetable data
  Future<void> _saveTimetable() async {
    if (_formKey.currentState?.validate() ?? false) {
      final classID = _selectedClass;
      final teacherID = _selectedLecturer;
      final courseName = _courseNameController.text;
      final venue = _venueController.text;
      final classtime = DateTime(
        _selectedDate?.year ?? DateTime.now().year,
        _selectedDate?.month ?? DateTime.now().month,
        _selectedDate?.day ?? DateTime.now().day,
        _selectedTime?.hour ?? 0,
        _selectedTime?.minute ?? 0,
      );
      final duration = _selectedDuration ?? '1 Hour';

      try {
        final timetableRef = FirebaseFirestore.instance.collection('timetables').doc();
        await timetableRef.set({
          'timetableID': timetableRef.id,
          'classID': classID,
          'coursename': courseName,
          'teacherID': teacherID,
          'venue': venue,
          'classtime': Timestamp.fromDate(classtime),
          'duration': duration,
        });
        showTopSnackBar(
          context,
          'Saved Timetable Data!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        // Reset the form and clear controllers
        _formKey.currentState?.reset();
        _courseNameController.clear();
        _venueController.clear();

        // Reset dropdowns and other fields
        setState(() {
          _selectedClass = null;
          _selectedLecturer = null;
          _selectedDate = null;
          _selectedTime = null;
          _selectedDuration = null;
        });
      } catch (e) {
        showTopSnackBar(
          context,
          'Failed to Save Timetable Data!',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
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
                          'Add Timetable',
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
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                child: Column(
                  children: [
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _classOptions,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        final List<Map<String, dynamic>>? classes = snapshot.data;

                        return DropdownSearch<Map<String, dynamic>>(
                          popupProps: const PopupProps.menu(
                            showSelectedItems: true,
                            showSearchBox: true,
                          ),
                          items: classes!,
                          itemAsString: (item) => item['name']!,
                          compareFn: (item1, item2) => item1['id'] == item2['id'],
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Class',
                              border: const UnderlineInputBorder(),
                              labelStyle: TextStyle(
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                          selectedItem: classes.firstWhere(
                            (classItem) => classItem['id'] == _selectedClass,
                            orElse: () => {'id': '', 'name': 'Select Class'},
                          ),
                          onChanged: (Map<String, dynamic>? newValue) {
                            setState(() {
                              _selectedClass = newValue?['id'];
                            });
                          },
                          validator: (value) {
                            if (_selectedClass == null || _selectedClass!.isEmpty) {
                              return 'Please select a Class';
                            }
                            return null;
                          },
                        );
                      },
                    ),

                    SizedBox(height: 2.h),

                    TextFormField(
                      controller: _courseNameController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Course Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a course name';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 2.h),

                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _lecturerOptions,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        final List<Map<String, dynamic>>? lecturers = snapshot.data;

                        return DropdownSearch<Map<String, dynamic>>(
                          popupProps: const PopupProps.menu(
                            showSelectedItems: true,
                            showSearchBox: true,
                          ),
                          items: lecturers!,
                          itemAsString: (item) => item['name']!,
                          compareFn: (item1, item2) => item1['id'] == item2['id'],
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Lecturer',
                              border: const UnderlineInputBorder(),
                              labelStyle: TextStyle(
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                          selectedItem: lecturers.firstWhere(
                            (lecturer) => lecturer['id'] == _selectedLecturer,
                            orElse: () => {'id': '', 'name': 'Select Lecturer'},
                          ),
                          onChanged: (Map<String, dynamic>? newValue) {
                            setState(() {
                              _selectedLecturer = newValue?['id'];
                            });
                          },
                          validator: (value) {
                            if (_selectedLecturer == null || _selectedLecturer!.isEmpty) {
                              return 'Please select a Lecturer';
                            }
                            return null;
                          },
                        );
                      },
                    ),

                    SizedBox(height: 2.h),

                    TextFormField(
                      controller: _venueController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Class Venue',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the class venue';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 2.h),

                    GestureDetector(
                      onTap: () async {
                        await _selectDate(context);
                        await _selectTime(context);
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(),
                            labelText: _selectedDate == null || _selectedTime == null
                                ? 'Select Date & Time'
                                : 'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)} Time: ${_selectedTime!.format(context)}',
                          ),
                          validator: (value) {
                            if (_selectedDate == null || _selectedTime == null) {
                              return 'Please select date and time';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Duration',
                      ),
                      value: _selectedDuration,
                      items: <String>['1 Hour', '2 Hour', '3 Hour']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDuration = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a duration';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 12.h),

                    ElevatedButton(
                      onPressed: _saveTimetable,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(double.infinity, 50), 
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
