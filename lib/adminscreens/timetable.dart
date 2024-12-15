import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/adminscreens/adminsubpage/addtimetable.dart';
import 'package:studybunnies/adminscreens/giftcatalogue.dart';
import 'package:studybunnies/adminscreens/users.dart';
import 'package:studybunnies/adminwidgets/appbar.dart';
import 'package:studybunnies/adminwidgets/bottomnav.dart';
import 'package:studybunnies/adminwidgets/drawer.dart';
import 'package:studybunnies/adminwidgets/timetable.dart';
import 'package:studybunnies/authentication/session.dart';

class Timetablelist extends StatefulWidget {
  const Timetablelist({super.key});

  @override
  State<Timetablelist> createState() => _TimetablelistState();
}

class _TimetablelistState extends State<Timetablelist> {
  final Session session = Session();

  List<Map<String, String>> classname = [];
  String? selectedClass;
  String? selectedClassID;
  String? selectedDate;
   Map<String, List<Map<String, dynamic>>> timetableEntriesByDate = {};

  @override
  void initState() {
    super.initState();
    fetchClasses();
    _fetchUsernames();
  }

String convertTimeFormat(String timeStr) {
  // Parse the time string into a DateTime object
  DateTime time = DateFormat('HH:mm').parse(timeStr);
  
  // Format the time as 'h:mm a'
  return DateFormat('h:mm a').format(time);
}


String calculateEndTime(String startTimeStr, String duration) {
  // Parse the start time string into a DateTime object in 'h:mm a' format
  DateTime startTime = DateFormat('h:mm a').parse(startTimeStr);
  // check duration of hours and add them together to get class end time
  Duration durationToAdd;
  if (duration == "1 Hour") {
    durationToAdd = Duration(hours: 1);
  } else if (duration == "2 Hour") {
    durationToAdd = Duration(hours: 2);
  } else if (duration == "3 Hour") {
    durationToAdd = Duration(hours: 3);
  } else {
    throw ArgumentError("Invalid duration format");
  }

  // Calculate the end time by adding the duration to the start time
  DateTime endTime = startTime.add(durationToAdd);
  
  // Format the end time as 'h:mm a' (e.g., 4:01 PM)
  return DateFormat('h:mm a').format(endTime);
}
  // map and get userID and username for dropdown section
  final Map<String, String> userCache = {}; 
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
      print('Error fetching usernames: $e');
    }
  }

  String getUsername(String userId) {
    return userCache[userId] ?? 'No Username';
  }
  // map classID with class name
  Future<void> fetchClasses() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('classes').get();
    setState(() {
      classname = [
        {'classID': '', 'classname': 'Select a Class'}
      ] + snapshot.docs.map((doc) => {
        'classID': doc.id,
        'classname': doc['classname'] as String,
      }).toList();
      selectedClass = classname.isNotEmpty ? classname[0]['classname'] : null;
      selectedClassID = classname.isNotEmpty ? classname[0]['classID'] : null;
    });
  }
  // get timetable data based on the selected entries (classname)
  Future<Map<String, List<Map<String, dynamic>>>> fetchTimetables(String classID, String? date) async {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    DateTime? selectedDateTime = date != null ? formatter.parse(date) : null;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('timetables')
        .where('classID', isEqualTo: classID)
        .get();

    Map<String, List<Map<String, dynamic>>> groupedEntries = {};
    // get timetable data based on the selected entries (classtime) after selected the (classname)
    snapshot.docs.forEach((doc) {
      DateTime docDate = doc['classtime'] is Timestamp ? (doc['classtime'] as Timestamp).toDate() : doc['classtime'] as DateTime;
      String formattedDate = formatter.format(docDate);

      if (selectedDateTime == null || (docDate.year == selectedDateTime.year &&
          docDate.month == selectedDateTime.month &&
          docDate.day == selectedDateTime.day)) {

        if (!groupedEntries.containsKey(formattedDate)) {
          groupedEntries[formattedDate] = [];
        }
        groupedEntries[formattedDate]!.add({
          'classID': doc.id,
          'classtime': docDate,
          'coursename': doc['coursename'] as String,
          'duration': doc['duration'] as String,
          'teacherID': doc['teacherID'] as String,
          'timetableID': doc['timetableID'] as String,
          'venue': doc['venue'] as String,
        });
      }
    });

    return groupedEntries;
  }
  // show class options in bottom sheet when initiated
  void _showClassOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: classname.map((Map<String, String> item) {
              return ListTile(
                title: Text(item['classname']!),
                onTap: () async {
                  if (item['classID']!.isNotEmpty) {
                    setState(() {
                      selectedClass = item['classname'];
                      selectedClassID = item['classID'];
                      selectedDate = null; // Reset date selection when class changes
                    });
                  }
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
  // based on classname and classtime selected get the relevant timetable details
Future<List<String>> _fetchAvailableDates(String classID) async {
  final DateFormat formatter = DateFormat('dd-MM-yyyy');

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('timetables')
      .where('classID', isEqualTo: classID)
      .get();

  Set<String> dateSet = {};

  snapshot.docs.forEach((doc) {
    DateTime docDate = doc['classtime'] is Timestamp
        ? (doc['classtime'] as Timestamp).toDate()
        : doc['classtime'] as DateTime;

    dateSet.add(formatter.format(docDate));
  });

  return dateSet.toList();
}
// show list of dates under the bottom sheet
void _showDateOptionsBottomSheet() async {
  if (selectedClassID == null || selectedClassID!.isEmpty) {
    return; // Exit if no class is selected
  }

  List<String> dates = await _fetchAvailableDates(selectedClassID!);

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Select a Date'),
              onTap: () {
                setState(() {
                  selectedDate = null; // Reset date selection
                });
                Navigator.pop(context); // Close the bottom sheet
              },
            ),
            ...dates.map((String date) {
              return ListTile(
                title: Text(date),
                onTap: () {
                  setState(() {
                    selectedDate = date;
                    // Fetch and update timetable entries based on the selected class and date
                    fetchTimetables(selectedClassID!, selectedDate).then((entries) {
                      setState(() {
                        timetableEntriesByDate = entries;
                      });
                    });
                  });
                  Navigator.pop(context); // Close the bottom sheet
                },
              );
            }).toList(),
          ],
        ),
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.leftToRight,
              duration: const Duration(milliseconds: 305),
              child: const Giftlist(),
            ),
          );
        }
        if (details.delta.dx < -25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 305),
              child: const Userlist(),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: mainappbar(
          "Timetable",
          "This section includes the timetable for various classes.",
          context,
        ),
            floatingActionButton: FloatingActionButton(
        onPressed: () {
        Navigator.push(
          context, PageTransition(
          type: PageTransitionType.rightToLeft,
            duration: const Duration(milliseconds: 305),  
            child: const Addtimetable(),
          ),
        ); 
          // Add your action here
        },
        backgroundColor: const Color.fromARGB(255, 100, 30, 30), 
        shape: const CircleBorder(), 
        child: const Icon(Icons.add, color: Colors.white),
        ),
        bottomNavigationBar: navbar(0),
        drawer: const AdminDrawer(initialIndex: 1),
        body: Padding(
          padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40.w,
                    child: ElevatedButton(
                      onPressed: _showClassOptionsBottomSheet,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedClass ?? 'Select Class', style: const TextStyle(
                            color: Colors.black,
                          )),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Container(
                    width: 40.w,
                    child: ElevatedButton(
                      onPressed: _showDateOptionsBottomSheet,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedDate ?? 'Select Date', style: const TextStyle(
                            color: Colors.black,
                          )),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
  child: Padding(
    padding: EdgeInsets.only(left: 0.w, right: 0.w, top: 2.h),
    child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
      future: selectedClassID != null && selectedClassID!.isNotEmpty && selectedDate != null
          ? fetchTimetables(selectedClassID!, selectedDate)
          : Future.value({}),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          Map<String, List<Map<String, dynamic>>> timetableEntriesByDate = snapshot.data ?? {};
          List<String> dates = timetableEntriesByDate.keys.toList();
          dates.sort((a, b) => DateFormat('dd-MM-yyyy').parse(a).compareTo(DateFormat('dd-MM-yyyy').parse(b)));
          //sorting of date

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: dates.isEmpty
                  ? [const Text("No Timetable Data Available")]
                  : dates.map((dateString) {
                      List<Map<String, dynamic>> entries = timetableEntriesByDate[dateString] ?? [];
                       entries.sort((a, b) {
                        DateTime startTimeA = a['classtime'] is Timestamp
                            ? (a['classtime'] as Timestamp).toDate()
                            : a['classtime'] as DateTime;
                        DateTime startTimeB = b['classtime'] is Timestamp
                            ? (b['classtime'] as Timestamp).toDate()
                            : b['classtime'] as DateTime;
                        return startTimeA.compareTo(startTimeB);
                      });
                      return Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Timetableheader(
                              DateFormat('EEEE, d/MM/yyyy').format(DateFormat('dd-MM-yyyy').parse(dateString)),
                            ),
                            SizedBox(height: 1.h),
                            ...entries.map((entry) {
                              String startTime = DateFormat('HH:mm').format(entry['classtime']);
                              String endTime = ""; 
                              print(endTime);
                              
                              return Timetablecontent(
                                context,
                                entry['coursename'],
                                getUsername(entry['teacherID']), // Replace with actual teacher's name
                                entry['venue'],
                                startTime = convertTimeFormat(startTime),
                                endTime = calculateEndTime(startTime, entry['duration']),
                                entry['timetableID'],
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    }).toList(),
            ),
          );
        }
      },
    ),
  ),
  ),
  ],
  )
        ),
      ),
    );
  }}
