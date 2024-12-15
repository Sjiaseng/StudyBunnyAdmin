import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:studybunnies/adminscreens/classes.dart';
import 'package:studybunnies/adminscreens/dashboard.dart';
import 'package:studybunnies/adminscreens/faq.dart';
import 'package:studybunnies/adminscreens/feedback.dart';
import 'package:studybunnies/adminscreens/giftcatalogue.dart';
import 'package:studybunnies/adminscreens/myprofile.dart';
import 'package:studybunnies/adminscreens/timetable.dart';
import 'package:studybunnies/adminscreens/users.dart';
import 'package:studybunnies/authentication/session.dart';

class AdminDrawer extends StatefulWidget {
  final int initialIndex;
  const AdminDrawer({super.key, required this.initialIndex});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}
 // drawer for main and sub pages (navigate to which section using switch statements)
class _AdminDrawerState extends State<AdminDrawer> {
  late int _currentIndex;
  final Session session = Session();

  @override
  void initState() {
    super.initState();
    _fetchUserData2();
    _currentIndex = widget.initialIndex;
    
  }
  String? newuserId;
  String? newuserName;
  String? newprofileImage;

  Future<void> _fetchUserData2() async {
    try {
      // Get the user ID from the session
      newuserId = await session.getUserId();
      if (newuserId == null) {
        print('User ID is null.');
        return;
      }

      // Fetch user document from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(newuserId!).get();
      if (!userDoc.exists) {
        print('User document does not exist.');
        return;
      }

      // Update state with fetched data
      setState(() {
        newuserName = userDoc.get('username');
        newprofileImage = userDoc.get('profile_img');
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _onDrawerItemTapped(int index, Widget page) {
    setState(() {
      _currentIndex = index;
    });

    Navigator.pop(context);
    Timer(const Duration(milliseconds: 205), () {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 205),
          child: page,
        ),
      );
    });
  }



  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd-MM-yyyy (E)').format(DateTime.now());
    TextStyle selectedStyle = TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color.fromRGBO(195, 154, 29, 1));
    TextStyle normalStyle = TextStyle(fontSize: 12.sp, color: Colors.white);
    Color selectedIconColor = const Color.fromRGBO(195, 154, 29, 1);
    Color unselectedIconColor = Colors.white;
    Color selectedContainerColor = Colors.yellow.withOpacity(0.2);
    Color unselectedContainerColor = Colors.transparent;

    return Drawer(
      backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 2.w),
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(
                  height: 7.h,
                ),
             Padding(
                padding: EdgeInsets.only(left: 7.w),
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    image: DecorationImage(
                      image: newprofileImage != null && newprofileImage != ""
                          ? NetworkImage(newprofileImage!)
                          : const AssetImage('images/profile.webp'),
                      fit: BoxFit.cover,  
                    ),
                  ),
                ),
              ),
                SizedBox(height: 2.h),
                Padding(
                  padding: EdgeInsets.only(left: 7.w),
                  child: Text(
                    '$newuserName',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 7.w),
                  child: Text(
                    'ID: $newuserId',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontFamily: 'Roboto',
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buildDrawerItem(
                index: 0,
                icon: Icons.home,
                text: 'Home',
                page: const AdminDashboard(),
                selectedIconColor: selectedIconColor,
                unselectedIconColor: unselectedIconColor,
                selectedStyle: selectedStyle,
                normalStyle: normalStyle,
                selectedContainerColor: selectedContainerColor,
                unselectedContainerColor: unselectedContainerColor,
              ),
              _buildDrawerItem(
                index: 1,
                icon: Icons.table_chart,
                text: 'Timetable',
                page: const Timetablelist(),
                selectedIconColor: selectedIconColor,
                unselectedIconColor: unselectedIconColor,
                selectedStyle: selectedStyle,
                normalStyle: normalStyle,
                selectedContainerColor: selectedContainerColor,
                unselectedContainerColor: unselectedContainerColor,
              ),
              _buildDrawerItem(
                index: 2,
                icon: Icons.class_,
                text: 'Classes',
                page: const Classlist(),
                selectedIconColor: selectedIconColor,
                unselectedIconColor: unselectedIconColor,
                selectedStyle: selectedStyle,
                normalStyle: normalStyle,
                selectedContainerColor: selectedContainerColor,
                unselectedContainerColor: unselectedContainerColor,
              ),
              _buildDrawerItem(
                index: 3,
                icon: Icons.person,
                text: 'Users',
                page: const Userlist(),
                selectedIconColor: selectedIconColor,
                unselectedIconColor: unselectedIconColor,
                selectedStyle: selectedStyle,
                normalStyle: normalStyle,
                selectedContainerColor: selectedContainerColor,
                unselectedContainerColor: unselectedContainerColor,
              ),
              _buildDrawerItem(
                index: 4,
                icon: Icons.card_giftcard_rounded,
                text: 'Gift Catalogue',
                page: const Giftlist(),
                selectedIconColor: selectedIconColor,
                unselectedIconColor: unselectedIconColor,
                selectedStyle: selectedStyle,
                normalStyle: normalStyle,
                selectedContainerColor: selectedContainerColor,
                unselectedContainerColor: unselectedContainerColor,
              ),
              _buildDrawerItem(
                index: 5,
                icon: Icons.autorenew_rounded,
                text: 'Feedback',
                page: const Feedbacklist(),
                selectedIconColor: selectedIconColor,
                unselectedIconColor: unselectedIconColor,
                selectedStyle: selectedStyle,
                normalStyle: normalStyle,
                selectedContainerColor: selectedContainerColor,
                unselectedContainerColor: unselectedContainerColor,
              ),
              _buildDrawerItem(
                index: 6,
                icon: Icons.person_pin,
                text: 'My Profile',
                page: const MyProfile(),
                selectedIconColor: selectedIconColor,
                unselectedIconColor: unselectedIconColor,
                selectedStyle: selectedStyle,
                normalStyle: normalStyle,
                selectedContainerColor: selectedContainerColor,
                unselectedContainerColor: unselectedContainerColor,
              ),
              _buildDrawerItem(
                index: 7,
                icon: Icons.warning,
                text: 'FAQ',
                page: const Faqpage(),
                selectedIconColor: selectedIconColor,
                unselectedIconColor: unselectedIconColor,
                selectedStyle: selectedStyle,
                normalStyle: normalStyle,
                selectedContainerColor: selectedContainerColor,
                unselectedContainerColor: unselectedContainerColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required int index,
    required IconData icon,
    required String text,
    required Widget page,
    required Color selectedIconColor,
    required Color unselectedIconColor,
    required TextStyle selectedStyle,
    required TextStyle normalStyle,
    required Color selectedContainerColor,
    required Color unselectedContainerColor,
  }) {
    return Container(
      color: _currentIndex == index
          ? selectedContainerColor
          : unselectedContainerColor,
      child: ListTile(
        title: Padding(
          padding: EdgeInsets.only(left: 5.w),
          child: Row(
            children: [
              Icon(
                icon,
                color: _currentIndex == index
                    ? selectedIconColor
                    : unselectedIconColor,
              ),
              const SizedBox(width: 10),
              Text(
                text,
                style: _currentIndex == index ? selectedStyle : normalStyle,
              ),
            ],
          ),
        ),
        selected: _currentIndex == index,
        onTap: () => _onDrawerItemTapped(index, page),
      ),
    );
  }
}
