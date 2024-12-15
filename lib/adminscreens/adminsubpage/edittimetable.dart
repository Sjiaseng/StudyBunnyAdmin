import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:studybunnies/adminwidgets/top_snack_bar.dart';

class Edittimetable extends StatefulWidget {
  final String timetableID;
  const Edittimetable({super.key, required this.timetableID});

  @override
  State<Edittimetable> createState() => _EdittimetableState();
}

class _EdittimetableState extends State<Edittimetable> {
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
    _fetchTimetableDetails();
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _venueController.dispose();
    super.dispose();
  }
    // function to update or modify data
    Future<void> _updateTimetable() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final updatedData = {
          'classID': _selectedClass,
          'teacherID': _selectedLecturer,
          'coursename': _courseNameController.text,
          'venue': _venueController.text,
          'duration': _selectedDuration,
          'classtime': Timestamp.fromDate(DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          )),
        };
        // modify timetable
        await FirebaseFirestore.instance
            .collection('timetables')
            .doc(widget.timetableID)
            .update(updatedData);

        showTopSnackBar(
          context,
          'Timetable Updated Successfully!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pop(context);
      } catch (e) {
        showTopSnackBar(
          context,
          'Failed to Update Timetable!',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        print("Error Updating Data: $e");
      }
    }
  }

  // Get timetable data from firestore based on timetableID
 Future<void> _fetchTimetableDetails() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('timetables').doc(widget.timetableID).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _selectedClass = data['classID'];
          _selectedLecturer = data['teacherID'];
          _selectedDuration = data['duration'];
          _courseNameController.text = data['coursename'] ?? '';
          _venueController.text = data['venue'] ?? '';
          _selectedDate = (data['classtime'] as Timestamp).toDate();
          _selectedTime = TimeOfDay.fromDateTime(_selectedDate!);
        });
      }
    } catch (e) {
      print("Error Fetching Data: $e");
    }
  }
  // Delete timetable data using timetableID
  Future<void> _deleteTimetable() async {
    try {
      await FirebaseFirestore.instance.collection('timetables').doc(widget.timetableID).delete();
      showTopSnackBar(
        context,
        'Deleted Timetable Data!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pop(context);
    } catch (e) {
      showTopSnackBar(
        context,
        'Failed to Delete Timetable Data!',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
  // Get class data and map classID with classname
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
  // Get user with teacher role in database and map their userID with username
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
  // date range to display in calendar
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
  // Get time through calling timepicker
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
                          'Edit Timetable',
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
                    onPressed: () {
                      _updateTimetable();
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
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),

                  ElevatedButton(
                    onPressed: () {
                      _deleteTimetable();
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
                      'Delete Timetable',
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
      ),
    );
  }
}
