import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/adminscreens/myprofile.dart';
import 'package:studybunnies/authentication/logoutscreen.dart';
// app bar widget used in main pages
AppBar mainappbar(String title, String helpmsg, BuildContext context) {
  return AppBar(
    backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color.fromRGBO(239, 238, 233, 1)),),

        SizedBox(width: 2.w),

        Tooltip(
          message: helpmsg, 
          child: Padding(
            padding: EdgeInsets.only(top: 0.5.h),
            child: Icon(
              Icons.help_outline,
              size: 1.5.h,
              color: const Color.fromRGBO(239, 238, 233, 1),
            ),
          ),
        ),
      ],
    ),
    actions: [
      IconButton(
        icon: Icon(
          Icons.person_pin,
          size: 3.0.h, 
          color: const Color.fromRGBO(239, 238, 233, 1),
        ),
        onPressed: () {
          Navigator.push(
            context, PageTransition(
              type: PageTransitionType.topToBottom,
              duration: const Duration(milliseconds: 305),  
              child: const MyProfile()
            )    
          );  
        },
      ),
      IconButton(
        icon: Icon(
          Icons.logout,
          size: 3.0.h, 
          color: const Color.fromRGBO(239, 238, 233, 1),
        ),
        onPressed: () {
          Navigator.push(
            context, PageTransition(
              type: PageTransitionType.topToBottom,
              duration: const Duration(milliseconds: 305),  
              child: const Logoutscreen()
            )    
          );  
        },
      ),
    ],
    leading: Builder(
      builder: (BuildContext context) {
        return IconButton(
          icon: const Icon(
            Icons.menu,
            color: Color.fromRGBO(239, 238, 233, 1), // Change the color of the drawer icon here
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        );
      },
    ),
  );
}
// appbar used in sub pages
AppBar subappbar(String title, BuildContext context) {
  return AppBar(
    backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color.fromRGBO(239, 238, 233, 1)),),

        SizedBox(width: 2.w),
      ],
    ),
    actions: [
      IconButton(
        icon: Icon(
          Icons.person_pin,
          size: 3.0.h, 
          color: const Color.fromRGBO(239, 238, 233, 1),
        ),
        onPressed: () {
          Navigator.push(
            context, PageTransition(
              type: PageTransitionType.topToBottom,
              duration: const Duration(milliseconds: 305),  
              child: const MyProfile()
            )    
          );  
        },
      ),

      IconButton(
        icon: Icon(
          Icons.logout,
          size: 3.0.h, 
          color: const Color.fromRGBO(239, 238, 233, 1),
        ),
        onPressed: () {
          Navigator.push(
            context, PageTransition(
              type: PageTransitionType.topToBottom,
              duration: const Duration(milliseconds: 305),  
              child: const Logoutscreen()
            )    
          );  
        },
      ),
    ],
  leading: GestureDetector( 
    onTap: (){
      Navigator.pop(context);
    },
    child: const Icon(
    Icons.arrow_back,
    color: Colors.white,
  ),
  ),
  );
}
