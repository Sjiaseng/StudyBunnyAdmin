import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:studybunnies/adminwidgets/top_snack_bar.dart';
import 'package:studybunnies/authentication/session.dart';

class HistoryListView extends StatefulWidget {
  const HistoryListView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HistoryListViewState createState() => _HistoryListViewState();
}
// display the list of histories of gifts exchange made by students
class _HistoryListViewState extends State<HistoryListView> {
  final Map<String, String> userCache = {}; // Cache for usernames
  final Map<String, String> giftNameCache = {}; // Cache for gift names
  final Map<String, String> giftImageCache = {}; // Cache for gift images
  final Session session = Session();

  Future<void> updateHistoryDocument(String historyId, Map<String, dynamic> updatedData) async {
    try {
      final historyCollection = FirebaseFirestore.instance.collection('giftshistory');
      await historyCollection.doc(historyId).update(updatedData);
      
      showTopSnackBar(
        context,
        'History Updated Successfully!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      print('Error updating document: $e');
      showTopSnackBar(
        context,
        'History Update Failed!',
        backgroundColor: const Color.fromARGB(255, 246, 77, 65),
        textColor: Colors.white,
      );
    }
  }

  Future<void> updateRecord(String updateHistoryID) async {
    try {
      String? adminID = await session.getUserId(); // Fetch the user ID to use for adminID

      Map<String, dynamic> updatedData = {
        'status': 1, // Set status to 1
        'adminID': adminID, // Set adminID to the fetched user ID
        'redeemdate': Timestamp.now(), // Set redeem date to the current timestamp
      };

      await updateHistoryDocument(updateHistoryID, updatedData);
    } catch (e) {
      print('Error updating record: $e');
      // Handle errors if necessary
    }
  }

  Future<void> deleteHistoryDocument(String historyId) async {
    try {
      final historyCollection = FirebaseFirestore.instance.collection('giftshistory');
      await historyCollection.doc(historyId).delete();
      
      showTopSnackBar(
        context,
        'History Deleted Successfully!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      print('Error deleting document: $e');
      showTopSnackBar(
        context,
        'History Delete Failed!',
        backgroundColor: const Color.fromARGB(255, 246, 77, 65),
        textColor: Colors.white,
      );
    }
  }

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

  Future<void> _fetchGiftNames() async {
    try {
      final giftsSnapshot = await FirebaseFirestore.instance.collection('gifts').get();
      final giftDocs = giftsSnapshot.docs;

      setState(() {
        for (var doc in giftDocs) {
          giftNameCache[doc.id] = doc['giftName'] ?? 'Unknown Gift';
        }
      });
    } catch (e) {
      print('Error fetching gift names: $e');
    }
  }

  String getGiftName(String giftId) {
    return giftNameCache[giftId] ?? 'Unknown Gift';
  }

  Future<void> _fetchGiftImages() async {
    try {
      final giftsSnapshot = await FirebaseFirestore.instance.collection('gifts').get();
      final giftDocs = giftsSnapshot.docs;

      setState(() {
        for (var doc in giftDocs) {
          giftImageCache[doc.id] = doc['gift_image'] ?? 'images/profile.webp';
        }
      });
    } catch (e) {
      print('Error fetching gift images: $e');
    }
  }

  String getGiftImage(String giftId) {
    return giftImageCache[giftId] ?? 'images/profile.webp';
  }

  @override
  void initState() {
    super.initState();
    _fetchUsernames();
    _fetchGiftNames();
    _fetchGiftImages();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('giftshistory').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('images/norecord.png'),
              ],
            );
          }
          final historyList = snapshot.data!.docs;

          // Sort historyList based on status and requestdate
          historyList.sort((a, b) {
            final statusA = a['status'] as int? ?? 1; // Ensure status is an integer
            final statusB = b['status'] as int? ?? 1;
            final requestDateA = (a['requestdate'] as Timestamp?)?.toDate() ?? DateTime.now();
            final requestDateB = (b['requestdate'] as Timestamp?)?.toDate() ?? DateTime.now();

            // Sort by status (0 on top, 1 on bottom) and then by request date (latest to earliest)
            if (statusA != statusB) {
              return statusA.compareTo(statusB);
            } else {
              return requestDateB.compareTo(requestDateA);
            }
          });

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              var history = historyList[index].data() as Map<String, dynamic>;
              String historyID = historyList[index].id;
              DateTime requestDate = (history['requestdate'] as Timestamp?)?.toDate() ?? DateTime.now();
              DateTime? redeemDate = (history['redeemdate'] as Timestamp?)?.toDate();
              String userID = history['userID'] ?? 'Unknown User';
              String adminID = history['adminID'] ?? 'Pending';
              String giftID = history['giftID'] ?? 'No Records Found';
              int status = history['status'] as int? ?? 0; // Ensure status is an integer

              String giftName = getGiftName(giftID);
              String giftImage = getGiftImage(giftID);
              String Student_username = getUsername(userID);
              String Admin_username = getUsername(adminID);

              String formattedRequestDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(requestDate);
              String formattedRedeemDate = redeemDate != null ? DateFormat('dd/MM/yyyy HH:mm:ss').format(redeemDate) : 'Pending';

              return Container(
                margin: EdgeInsets.only(bottom: 2.h),
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(217, 217, 217, 1),
                  border: Border.all(color: const Color.fromRGBO(217, 217, 217, 1), width: 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 5.w, bottom: 0.2.h),
                          child: Container(
                            width: 25.w,
                            height: 18.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: NetworkImage(giftImage), // Use the gift image from the cache
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Request Date: $formattedRequestDate',
                                style: TextStyle(
                                  color: const Color.fromRGBO(116, 116, 116, 1),
                                  fontFamily: 'Roboto',
                                  fontSize: 8.sp,
                                ),
                              ),
                              SizedBox(height: 0.5.h),

                              Tooltip(
                                message: Student_username,
                                child: SizedBox(
                                  width: 50.w,
                                  height: 2.h,
                                  child: Text(
                                    Student_username,
                                    maxLines: 1,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 0.8.h),

                              SizedBox(
                                width: 50.w,
                                child: Text(
                                  'Gift Name: $giftName',
                                  maxLines: 1,
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 9.sp,
                                  ),
                                ),
                              ),

                              SizedBox(height: 0.5.h),

                              Text(
                                'Redeem Time: $formattedRedeemDate',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                ),
                              ),

                              SizedBox(height: 0.5.h),

                              SizedBox(
                                width: 50.w,
                                child: Text(
                                  'Admin Name: ${Admin_username == 'No Username' ? 'Pending' : Admin_username}',
                                  maxLines: 1,
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 9.sp,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 13.h,
                      left: 34.5.w,
                      child: SizedBox(
                        width: 38.w,
                        child: ElevatedButton(
                          onPressed: status == 0 ? () => updateRecord(historyID) : null,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                            backgroundColor: status == 0 ? const Color.fromRGBO(116, 116, 116, 1) : Colors.grey, // Change color if disabled
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            status == 0 ? 'Redeem' : 'Redeemed', // Change text based on status
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 13.h,
                      left: 75.w,
                      child: SizedBox(
                        width: 10.w,
                        child: ElevatedButton(
                          onPressed: () {
                            deleteHistoryDocument(historyID);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                            backgroundColor: const Color.fromRGBO(116, 116, 116, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
