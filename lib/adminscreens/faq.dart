import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Faqpage extends StatefulWidget {
  const Faqpage({super.key});

  @override
  State<Faqpage> createState() => _FaqpageState();
}
// check which listtile is extended
class _FaqpageState extends State<Faqpage> {
  final List<bool> _isOpen = [false, false, false, false, false, false, false]; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
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
                    child: Icon(Icons.arrow_back, size: 20.sp,),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(left: 35.w, top: 3.h),
                    child: Text(
                      'FAQ',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            
            Container(
              margin: EdgeInsets.only(top: 2.h),
              padding: EdgeInsets.only(left: 10.w, right: 10.w),
              
              child: ExpansionPanelList(
                animationDuration: 
                const Duration(seconds: 1),
                elevation: 1,
                
                dividerColor: Colors.grey, 
                children: [
                  _buildExpansionPanel(0, 'Q: What is StudyBunnies?', 'Answer:', 'StudyBunnies is a mobile application that facilitates interactive learning between students and teachers.'),
                  _buildExpansionPanel(1, 'Q: How do I get started?', 'Answer:', 'Download the StudyBunnies app from the [app store](URL play store) or [app store](URL apple app store). Sign up for a free account as a student, teacher, or admin according to your role.'),
                  _buildExpansionPanel(2, 'Q: Benefits of StudyBunnies?', 'Answer', 'Students can access class notes, participate in quizzes, track their progress, and earn rewards. Teachers can upload content, manage quizzes and tests, monitor student performance, and communicate with students. Admins can manage users, classes, the gift catalogue, timetable, and moderate comments and feedback.'),
                  _buildExpansionPanel(3, 'Q: Is StudyBunnies free to use?', 'Answer', 'While the core functionalities of StudyBunnies might be free, you can consider mentioning if there are any premium features or in-app purchases available for additional benefits.'),
                  _buildExpansionPanel(4, 'Q: Device Compatibility?', 'Answer', 'Indicate whether the app is available for Android, iOS, or both.'),
                  _buildExpansionPanel(5, 'Q: Community Guidelines? ', 'Answer', 'Outline any specific guidelines users should follow when interacting with others on the platform. This could cover topics like respectful communication, avoiding plagiarism, or reporting inappropriate content.'),
                  _buildExpansionPanel(6, 'Q: Forget Password?', 'Answer', 'Explain the process for recovering a forgotten password.'),
                ],
                expansionCallback: (int index, bool isOpen) {
                  setState(() {
                    _isOpen[index] = !_isOpen[index];
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  // widget of expandable panel with takes information as parameters
ExpansionPanel _buildExpansionPanel(int index, String headerTitle, String bodyTitle, String bodySubtitle) {
  return ExpansionPanel(
    canTapOnHeader: true,
    backgroundColor: Colors.white,
    headerBuilder: (context, isOpen) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: EdgeInsets.only(bottom: 0.75.h, top:0.75.h),
        child: ListTile(
          title: Text(headerTitle, maxLines: 1, style:TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10.sp,
            overflow: TextOverflow.ellipsis,
          ),
          ),
        ),
      );
    },
    body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
      margin: EdgeInsets.only(bottom: 3.h),
      child: ListTile(
        tileColor:  Colors.white,
        title: Text(bodyTitle),
        subtitle: Text(bodySubtitle), 
      ),
    ),
    isExpanded: _isOpen[index],
  );
}
}
