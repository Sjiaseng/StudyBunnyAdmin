import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:studybunnies/adminwidgets/top_snack_bar.dart'; 

class Addclass extends StatefulWidget {
  const Addclass({super.key});

  @override
  State<Addclass> createState() => _AddclassState();
}

class _AddclassState extends State<Addclass> {
  final ImagePicker _picker = ImagePicker();
  String? _pickedImagePath;
  bool _isChecked = false;
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Pick Image and Handle Image Path / Data
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImagePath = pickedFile.path;
      });
    }
  }

  // Ensure Users Included Class Image & Agree with T&C of StudyBunnies
  Future<void> _uploadClass() async {
    if (!_formKey.currentState!.validate() || _pickedImagePath == null || !_isChecked) {
      if (_pickedImagePath == null) {
        showTopSnackBar(
          context,
          'Please Upload a Class Image!',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } else if (!_isChecked) {
        showTopSnackBar(
          context,
          'You Must Agree with the Terms & Conditions!',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      return;
    }

    try {
      // Fetching Data from Classes Doc
      DocumentReference docRef = FirebaseFirestore.instance.collection('classes').doc();
      String docID = docRef.id;
      // Check is there a new file added
      File imageFile = File(_pickedImagePath!);
      UploadTask uploadTask = FirebaseStorage.instance.ref().child('class_images').child(docID).putFile(imageFile);

      // Get Image URL in Firebase Storage
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      // Update the Class Data
      await docRef.set({
        'classID': docID, 
        'classname': _classNameController.text,
        'class_desc': _descriptionController.text,
        'class_img': imageUrl,
        'student':[],
        'lecturer':[],
      });
      // Alert Message
      showTopSnackBar(
        context,
        'Class Added Successfully',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      _classNameController.clear();
      _descriptionController.clear();
      setState(() {
        _pickedImagePath = null;
        _isChecked = false;
      });
      // Error Handling
    } catch (e) {
      showTopSnackBar(
        context,
        'Failed to Add Class. Please Try Again!',
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
                          'Adding Class',
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
                  "Class: Auto Generated",
                  style: TextStyle(
                    fontSize: 8.sp,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis, // Handle long user ID
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _classNameController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Class Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter a Class Name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height:4.h),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 7,
                      scrollPhysics: const BouncingScrollPhysics(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Description',
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(
                          fontSize: 16.0,
                        ),
                        contentPadding: EdgeInsets.only(left: 12.0, top: 12.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter a Description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Checkbox(
                          value: _isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              _isChecked = value!;
                            });
                          },
                        ),
                        SizedBox(
                          width: 63.w,
                          child: const Text(
                            "I Agree with the Terms & Conditions of StudyBunnies",
                            maxLines: 2,
                            style: TextStyle(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    ElevatedButton(
                      onPressed: _uploadClass,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(double.infinity, 50), // Ensures the button takes full width
                      ),
                      child: const Text(
                        'Add Class',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
