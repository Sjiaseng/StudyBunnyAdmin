import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:studybunnies/adminwidgets/IncrementDecrement.dart';
import 'package:studybunnies/adminwidgets/top_snack_bar.dart';

class Addgift extends StatefulWidget {
  const Addgift({super.key});

  @override
  State<Addgift> createState() => _AddgiftState();
}

class _AddgiftState extends State<Addgift> {
  final ImagePicker _picker = ImagePicker();
  String? _pickedImagePath;
  final TextEditingController _giftNameController = TextEditingController();
  final TextEditingController _giftDescriptionController = TextEditingController();
  final TextEditingController _pointsAmountController = TextEditingController();
  final TextEditingController _stockAmountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Handle Image Picking Process
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImagePath = pickedFile.path;
      });
    }
  }
  // Ensure users to upload gift picture
  Future<void> _uploadGift() async {
    if (!_formKey.currentState!.validate() || _pickedImagePath == null) {
      if (_pickedImagePath == null) {
        showTopSnackBar(
          context,
          'Please Upload a Gift Image!',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      return;
    }

    try {
      // Create a new document reference with an auto-generated ID
      DocumentReference docRef = FirebaseFirestore.instance.collection('gifts').doc();
      String docID = docRef.id;

      // Use the generated document ID as the file name for the image upload
      File imageFile = File(_pickedImagePath!);
      UploadTask uploadTask = FirebaseStorage.instance.ref().child('gift_images').child(docID).putFile(imageFile);

      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      // Insert Data Based on Response
      await docRef.set({
        'giftID': docID, // Use the auto-generated document ID as the giftID
        'giftName': _giftNameController.text,
        'description': _giftDescriptionController.text,
        'points_required': int.parse(_pointsAmountController.text),
        'stock_amount': int.parse(_stockAmountController.text),
        'gift_image': imageUrl,
      });

      showTopSnackBar(
        context,
        'Gift Added Successfully',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      _giftNameController.clear();
      _giftDescriptionController.clear();
      _pointsAmountController.clear();
      _stockAmountController.clear();
      setState(() {
        _pickedImagePath = null;
      });

    } catch (e) {
      showTopSnackBar(
        context,
        'Failed to Add Gift. Please Try Again!',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
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
                          'Adding Gift',
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
              SizedBox(height: 2.h),
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: _pickedImagePath != null
                              ? FileImage(File(_pickedImagePath!))
                              : const AssetImage('images/addimage.png') as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: IconButton(
                            icon: Icon(Icons.camera_alt, size: 4.5.w, color: Colors.white),
                            onPressed: _pickImage,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Gift ID: Auto Generated",
                  style: TextStyle(
                    fontSize: 8.sp,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _giftNameController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Gift Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter a Gift Name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      controller: _giftDescriptionController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Gift Description',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter a Gift Description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      controller: _pointsAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Points Amount (pts.)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter the Points Amount';
                        }
                        if (RegExp(r'[^0-9]').hasMatch(value)) {
                          return 'Please Enter a Valid Number';
                        }
                        if (int.tryParse(value) == null || int.parse(value) < 1) {
                          return 'Please Enter a Valid Number';
                        }
                        return null;
                      }
                    ),
                    SizedBox(height: 2.h),
                    IncrementDecrementFormField(
                      labelText: 'Stock Amount',
                      controller: _stockAmountController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter the Stock Amount';
                        }
                        if (RegExp(r'[^0-9]').hasMatch(value)) {
                          return 'Please Enter a Valid Number';
                        }
                        if (int.tryParse(value) == null || int.parse(value) < 1) {
                          return 'Please Enter a Valid Number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _uploadGift,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    )
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
