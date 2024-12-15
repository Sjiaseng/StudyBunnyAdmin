import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
// summary containers (used in dashboard to show the summary report)
Widget SummaryContainer(String title, Color color, String value) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: color,
        ),
        height: 20.w,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                value,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

