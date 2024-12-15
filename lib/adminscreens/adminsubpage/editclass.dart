import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:studybunnies/adminscreens/classes.dart';
import 'package:studybunnies/adminwidgets/top_snack_bar.dart'; 
import 'package:page_transition/page_transition.dart';

class Editclass extends StatefulWidget {
  final String classID;
  const Editclass({super.key, required this.classID});

  @override
  State<Editclass> createState() => _EditclassState();
}

class _EditclassState extends State<Editclass> {
  String? _pickedImagePath;
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  String? _originalImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchClassData();
  }
  // Handle input Image
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImagePath = pickedFile.path;
      });
    }
  }
  // Get class Data and Display Them in respective textfield or etc...
  Future<void> _fetchClassData() async {
    try {
      final classDoc = await FirebaseFirestore.instance.collection('classes').doc(widget.classID).get();
      if (classDoc.exists) {
        final data = classDoc.data()!;
        setState(() {
          _classNameController.text = data['classname'] ?? '';
          _descriptionController.text = data['class_desc'] ?? '';
          _originalImageUrl = data['class_img'];
          _pickedImagePath = _originalImageUrl;
        });
      }
    } catch (e) {
      print('Error fetching class data: $e');
    }
  }
  // update class information
Future<void> _updateClass() async {
  if (_formKey.currentState!.validate()) {
    final classCollection = FirebaseFirestore.instance.collection('classes');

    try {
      String imageUrl = _originalImageUrl ?? '';

      // Upload new image if a new one is picked
      if (_pickedImagePath != null && !_pickedImagePath!.startsWith('http')) {
        File file = File(_pickedImagePath!);

        if (!file.existsSync()) {
          throw Exception('File does not exist at path: ${file.path}');
        }

        // Upload the image and get the URL
        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref('class_images/${widget.classID}')
            .putFile(file);
        imageUrl = await snapshot.ref.getDownloadURL();

        // Update the image URL in Firestore
        setState(() {
          _originalImageUrl = imageUrl; // Update the original image URL
        });
      }

      // Update class document in Firestore
      await classCollection.doc(widget.classID).update({
        'classname': _classNameController.text,
        'class_desc': _descriptionController.text,
        'class_img': imageUrl,
      });

      if (mounted) {
        showTopSnackBar(
          context,
          'Class Info Updated Successfully!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error during form submission: $e');
      if (mounted) {
        showTopSnackBar(
          context,
          'Update Failed!',
          backgroundColor: const Color.fromARGB(255, 246, 77, 65),
          textColor: Colors.white,
        );
      }
    }
  } else {
    showTopSnackBar(
      context,
      'Please Fill All Required Fields!',
      backgroundColor: const Color.fromARGB(255, 246, 77, 65),
      textColor: Colors.white,
    );
  }
}

  // Delete class based on classID
  Future<void> _deleteClass() async {
    try {
      final classDoc = await FirebaseFirestore.instance.collection('classes').doc(widget.classID).get();
      if (classDoc.exists) {
        final data = classDoc.data()!;
        final imagePath = data['class_img'];

        if (imagePath != null && imagePath.isNotEmpty) {
          try {
            final storageRef = FirebaseStorage.instance.refFromURL(imagePath);
            await storageRef.delete();
            print('Image deleted successfully');
          } catch (e) {
            print('Error deleting image: $e');
          }
        }

        try {
          // Lines of code for deletion
          await FirebaseFirestore.instance.collection('classes').doc(widget.classID).delete();
          print('Document deleted successfully');
        } catch (e) {
          print('Error deleting document: $e');
        }
      }

      if (mounted) {
        showTopSnackBar(
          context,
          'Class Deleted Successfully!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 305),
              child: const Classlist(),
            ),
          );
      }
    } catch (e) {
      print('Error during Gift Deletion: $e');
      if (mounted) {
        showTopSnackBar(
          context,
          'Class Deletion Failed!',
          backgroundColor: const Color.fromARGB(255, 246, 77, 65),
          textColor: Colors.white,
        );
      }
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
                          'Edit Class',
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
                          image: _pickedImagePath != null && _pickedImagePath != ""
                              ? (_pickedImagePath!.contains('http')
                                  ? NetworkImage(_pickedImagePath!)
                                  : FileImage(File(_pickedImagePath!)) as ImageProvider)
                              : const AssetImage('images/addimage.png'),
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
                  'Class: ${widget.classID}',
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
                    SizedBox(height: 8.h),
                    ElevatedButton(
                      onPressed: (){
                        _updateClass();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(double.infinity, 50), // Ensures the button takes full width
                      ),
                      child: const Text(
                        'Edit Class',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    ElevatedButton(
                      onPressed: (){
                        _deleteClass();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.red, width: 2),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'Delete Class',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        )
                      )
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
