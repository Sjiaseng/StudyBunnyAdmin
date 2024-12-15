import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:studybunnies/adminscreens/adminsubpage/edittimetable.dart';
// widget for header in timetable which displays date
Widget Timetableheader(String mydate) {
  return Container(
    margin: EdgeInsets.only(bottom: 2.h),
    width: double.infinity,
    height: 5.h,
    decoration: BoxDecoration(
      color: const Color.fromRGBO(217, 217, 217, 1),
      border: Border.all(color: const Color.fromRGBO(217, 217, 217, 1), width: 1.0),
      borderRadius: BorderRadius.circular(8.0), // Added borderRadius
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w), // Added padding to avoid text being too close to the border
      child: Align(
        alignment: Alignment.centerLeft, // Align text to the left
        child: Text(
          mydate,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    ),
  );
}
// widget for timetable content based on the parameter included
Widget Timetablecontent(BuildContext context,String course_title, String lecturername, String venue, String timestart, String timeend, String timetableID) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context, PageTransition(
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 305),  
          child: Edittimetable(timetableID: timetableID),
        )
      ); 
    },
    child:InkWell(
    highlightColor: Colors.grey,
    borderRadius: BorderRadius.circular(8.0),
    focusColor: Colors.grey,
    child: Container(
      width: double.infinity,
      height: 20.h,
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(241, 241, 241, 1),
        border: Border.all(color: const Color.fromRGBO(217, 217, 217, 1), width: 1.0),
        borderRadius: BorderRadius.circular(8.0), 
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 5.w, right: 5.w), // Adjusted padding for the whole content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Ensures all children are aligned to the left
          children: [
            Padding(
              padding: EdgeInsets.only(top: 2.h), 
              child: Text(
                course_title,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14.sp,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: Text(
                lecturername,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12.sp,
                  overflow: TextOverflow.ellipsis,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 1.h),
                  child: Icon(Icons.location_on, 
                  size: 14.sp,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 1.h, left: 1.w),
                  child: Text(
                    venue,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ],
            ),

          Row(
            children: [
            Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: Icon(Icons.timelapse, 
              size: 14.sp,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 1.h, left: 1.w),
              child: Text(
                '$timestart - $timeend',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
            Text("Modify Timetable", style: TextStyle(
              color: Colors.grey,
              fontSize: 9.sp,
            ),
            ),
            Icon(Icons.arrow_right, color: Colors.grey, size: 14.sp),
          ],)

          ],
        ),
      ),
    ),
    ),
  );
}
