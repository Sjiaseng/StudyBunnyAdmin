import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/adminscreens/classes.dart';
import 'package:studybunnies/adminscreens/dashboard.dart';
import 'package:studybunnies/adminscreens/giftcatalogue.dart';
import 'package:studybunnies/adminscreens/timetable.dart';
import 'package:studybunnies/adminscreens/users.dart';
// based on selected index navigate to the options (index keep the bottom navigator active)
void navigateToPage(int index, BuildContext context) {
  switch (index) {
    case 0:
      Navigator.push(
        context, PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 505),  
        child: const Timetablelist()
        )
      );
      break;
    case 1:
      Navigator.push(
        context, PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 505),  
        child: const Userlist()
        )
      );
      break;
    case 2:
      Navigator.push(
        context, PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 505),  
        child: const AdminDashboard()
        )
      );
      break;
    case 3:
      Navigator.push(
        context, PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 505),  
        child: const Classlist()
        )
      );
      break;
    case 4:
      Navigator.push(
        context, PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 505),  
        child: const Giftlist()
        )
      );
      break;
  }
}

Widget navbar(int currentIndex) {
  return Sizer(
    builder: (context, orientation, deviceType) {
      return BottomNavigationBar(
        
        items: [
          _buildNavItem(Icons.table_chart_outlined, 'Timetable', currentIndex == 0, () => navigateToPage(0, context)),
          _buildNavItem(Icons.person_outline_rounded, 'Users', currentIndex == 1, () => navigateToPage(1, context)),
          _buildNavItem(Icons.home_outlined, 'Home', currentIndex == 2, () => navigateToPage(2, context)),
          _buildNavItem(Icons.class_outlined, 'Classes', currentIndex == 3, () => navigateToPage(3, context)),
          _buildNavItem(Icons.card_giftcard, 'Gift', currentIndex == 4, () => navigateToPage(4, context)),
        ],
        currentIndex: currentIndex,
        unselectedItemColor: const Color.fromRGBO(239, 238, 233, 1),
        unselectedFontSize: 9.5.sp,
        unselectedLabelStyle: const TextStyle(fontFamily: 'Roboto', color: Color.fromRGBO(239, 238, 233, 1)),

        selectedItemColor: const Color.fromRGBO(195, 154, 28, 1),
        selectedFontSize: 10.sp,
        selectedIconTheme: const IconThemeData(
          color: Color.fromRGBO(195, 154, 28, 1),
        ),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
        backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
  
        iconSize: 3.2.h,
        type: BottomNavigationBarType.fixed,
      );
    },
  );
}

BottomNavigationBarItem _buildNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
  return BottomNavigationBarItem(
    icon: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 7.0, top: 5.0),
        width: isSelected ? 18.w : 18.w, 
        height: isSelected ? 4.7.h : 4.7.h, 
        decoration: isSelected
            ? BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(100),
                color: const Color.fromRGBO(195, 154, 28, 0.3),
              )
            : null,
        child: Icon(icon),
      ),
    ),
    label: label,
  );
}

BottomNavigationBarItem _buildNavItem2(IconData icon, String label, VoidCallback onTap) {
  return BottomNavigationBarItem(
    icon: GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.only(bottom: 7.0, top: 5.0),
      width:  18.w, 
      height:  4.8.h,
      decoration:
        BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(100),
              color: Colors.transparent,
        ), 
      child: Icon(icon),
      ),
    ),
    label: label,
  );
}

Widget inactivenavbar() {
  return Sizer(
    builder: (context, orientation, deviceType) {
      return BottomNavigationBar(
        
        items: [
          _buildNavItem2(Icons.table_chart_outlined, 'Timetable', () => navigateToPage(0, context)),
          _buildNavItem2(Icons.person_outline_rounded, 'Users', () => navigateToPage(1, context)),
          _buildNavItem2(Icons.home_outlined, 'Home', () => navigateToPage(2, context)),
          _buildNavItem2(Icons.class_outlined, 'Classes', () => navigateToPage(3, context)),
          _buildNavItem2(Icons.card_giftcard, 'Gift', () => navigateToPage(4, context)),
        ],

        unselectedItemColor: const Color.fromRGBO(239, 238, 233, 1),
        unselectedFontSize: 9.5.sp,
        unselectedLabelStyle: const TextStyle(fontFamily: 'Roboto', color: Color.fromRGBO(239, 238, 233, 1)),
        
        backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
        selectedItemColor: const Color.fromRGBO(239, 238, 233, 1),
        selectedFontSize: 9.5.sp,
        selectedLabelStyle: const TextStyle(fontFamily: 'Roboto', color: Color.fromRGBO(239, 238, 233, 1)),

  
        iconSize: 3.2.h,
        type: BottomNavigationBarType.fixed,
      );
    },
  );
}
