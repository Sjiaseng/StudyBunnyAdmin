import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/adminwidgets/top_snack_bar.dart'; 

class Classcomment extends StatefulWidget {
  final String noteID;
  const Classcomment({super.key, required this.noteID});

  @override
  State<Classcomment> createState() => _ClasscommentState();
}

class _ClasscommentState extends State<Classcomment> {
  List<bool> _expandedStates = [];
  final Map<String, String> userCache = {}; 
  final Map<String, String> userCache2 = {}; 

  @override
  void initState() {
    super.initState();
    _fetchUsernames();
    _fetchUserProfile();
    _calculateNumberOfComments();
  }
  // Get username based on userID
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
  // Get user profile image based on userID
  Future<void> _fetchUserProfile() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final userDocs = usersSnapshot.docs;

      setState(() {
        for (var doc in userDocs) {
          userCache2[doc.id] = doc['profile_img'] ?? 'images/profile.webp';
        }
      });
    } catch (e) {
      print('Error fetching profile images: $e');
    }
  }

  String getUserProfile(String userId) {
    return userCache2[userId] ?? 'images/profile.webp';
  }
  // Determine How Many Comments under The Notes
  Future<void> _calculateNumberOfComments() async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('comments')
        .where('noteID', isEqualTo: widget.noteID)
        .get();

    setState(() {
      _expandedStates = List.generate(querySnapshot.docs.length, (_) => false);
    });
  }
  // Delete Comment based on commentID
  Future<void> deleteComment(String commentID) async {
    try {
      await FirebaseFirestore.instance.collection('comments').doc(commentID).delete();
      showTopSnackBar(
        context,
        'Comment Deleted Successfully!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      print('Error deleting comment: $e');
      showTopSnackBar(
        context,
        'Failed to Delete Comment!',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
  // Delete Reply under A comment with replyID
  Future<void> deleteReply(String replyID) async {
    try {
      await FirebaseFirestore.instance.collection('replies').doc(replyID).delete();
      showTopSnackBar(
        context,
        'Reply Deleted Successfully!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      print('Error deleting reply: $e');
      showTopSnackBar(
        context,
        'Failed to Delete Reply!',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(239, 238, 233, 1),
      body: SingleChildScrollView(
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
                        'Note Comments',
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
              padding: EdgeInsets.only(left: 5.5.w, right: 5.5.w),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('comments')
                    .where('noteID', isEqualTo: widget.noteID)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var comments = snapshot.data!.docs;

                  // Update _expandedStates if the number of comments changes
                  if (_expandedStates.length != comments.length) {
                    _expandedStates = List.generate(comments.length, (_) => false);
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      var comment = comments[index];
                      var commentContent = comment['commentContent'];
                      var commentID = comment.id; // Use document ID
                      var generationDate = (comment['generationDate'] as Timestamp).toDate();
                      var formattedDate = DateFormat('yyyy-MM-dd').format(generationDate);
                      var userID = comment['userID'];

                      var username = getUsername(userID);
                      var image = getUserProfile(userID);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            tileColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 1.h,
                              horizontal: 1.w,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 10.w,
                              backgroundImage: image != ''
                              ? NetworkImage(image)
                              : const AssetImage('images/profile.webp') as ImageProvider,
                            ),
                            title: Text(
                              username,
                              maxLines: 1,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 12.sp,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  commentContent,
                                  style: TextStyle(fontSize: 10.sp),
                                ),
                                SizedBox(height: 1.w),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(_expandedStates[index]
                                      ? Icons.expand_less
                                      : Icons.expand_more),
                                  onPressed: () {
                                    setState(() {
                                      _expandedStates[index] =
                                          !_expandedStates[index];
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    deleteComment(commentID);
                                  },
                                ),
                              ],
                            ),
                          ),
                          // Expanded Area
                          if (_expandedStates[index])
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('replies')
                                  .where('commentID', isEqualTo: commentID)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                var replies = snapshot.data!.docs;
                                return Container(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: replies.length,
                                    itemBuilder: (context, replyIndex) {
                                      var reply = replies[replyIndex];
                                      var replyContent = reply['replyContent'];
                                      var replyID = reply.id; // Use document ID
                                      var replyUserID = reply['userID'];
                                      var replyUsername = getUsername(replyUserID);
                                      var replyProfile = getUserProfile(replyUserID);

                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(color: Colors.grey, width: 0.1.w),
                                          ),
                                        ),
                                        child: ListTile(
                                          tileColor: Colors.white,
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 1.h,
                                            horizontal: 1.w,
                                          ),
                                          leading: Padding(
                                            padding: EdgeInsets.only(left: 5.w),
                                            child: CircleAvatar(
                                              backgroundColor: Colors.grey,
                                              backgroundImage: replyProfile != ''
                                              ? NetworkImage(replyProfile)
                                              : const AssetImage('images/profile.webp') as ImageProvider,
                                              radius: 5.w,
                                            ),
                                          ),
                                          title: Text(
                                            replyUsername,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              overflow: TextOverflow.ellipsis,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                replyContent,
                                                style: TextStyle(fontSize: 10.sp),
                                              ),
                                            ],
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                onPressed: () {
                                                  deleteReply(replyID);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          SizedBox(height: 2.h),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
