import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/adminwidgets/IncrementDecrement.dart';
import 'package:studybunnies/adminwidgets/top_snack_bar.dart';

class Editgift extends StatefulWidget {
  final String giftID;
  const Editgift({required this.giftID, super.key});

  @override
  State<Editgift> createState() => _EditgiftState();
}

class _EditgiftState extends State<Editgift> {
  final ImagePicker _picker = ImagePicker();
  String? _pickedImagePath;
  String? _originalImageUrl;

  final TextEditingController _giftNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pointsRequiredController = TextEditingController();
  final TextEditingController _stockAmountController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchGiftData(); // Fetch data when widget is initialized
  }

  @override
  void dispose() {
    _giftNameController.dispose();
    _descriptionController.dispose();
    _pointsRequiredController.dispose();
    _stockAmountController.dispose();
    super.dispose();
  }
  // handle image data
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImagePath = pickedFile.path;
      });
    }
  }
  // get gift data based on giftID from database
  Future<void> _fetchGiftData() async {
    try {
      final giftDoc = await FirebaseFirestore.instance.collection('gifts').doc(widget.giftID).get();
      if (giftDoc.exists) {
        final data = giftDoc.data()!;
        setState(() {
          _giftNameController.text = data['giftName'] ?? '';
          _descriptionController.text = data['description'] ?? '';
          _pointsRequiredController.text = data['points_required']?.toString() ?? '';
          _stockAmountController.text = data['stock_amount']?.toString() ?? '';
          _originalImageUrl = data['gift_image'];
          _pickedImagePath = _originalImageUrl;
        });
      }
    } catch (e) {
      print('Error fetching gift data: $e');
    }
  }
  // update information based on giftID
  Future<void> _updateGift() async {
    if (_formKey.currentState!.validate()) {
      final giftsCollection = FirebaseFirestore.instance.collection('gifts');

      try {
        String imageUrl = _originalImageUrl ?? '';

        if (_pickedImagePath != null && !_pickedImagePath!.startsWith('http')) {
          File file = File(_pickedImagePath!);

          if (!file.existsSync()) {
            throw Exception('File does not exist at path: ${file.path}');
          }

          TaskSnapshot snapshot = await FirebaseStorage.instance
              .ref('gift_images/${widget.giftID}')
              .putFile(file);
          imageUrl = await snapshot.ref.getDownloadURL();

          // Update the picked image path with the new URL
          setState(() {
            _originalImageUrl = imageUrl;
            _pickedImagePath = imageUrl;
          });
        }

        await giftsCollection.doc(widget.giftID).update({
          'giftName': _giftNameController.text,
          'description': _descriptionController.text,
          'points_required': int.parse(_pointsRequiredController.text),
          'stock_amount': int.parse(_stockAmountController.text),
          'gift_image': imageUrl,
        });

        if (mounted) {
          showTopSnackBar(
            context,
            'Gift Updated Successfully!',
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
  // delete gifts uploaded in the database based on giftID
  Future<void> _deleteGift() async {
    try {
      final giftDoc = await FirebaseFirestore.instance.collection('gifts').doc(widget.giftID).get();
      if (giftDoc.exists) {
        final data = giftDoc.data()!;
        final imagePath = data['gift_image'];

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
          await FirebaseFirestore.instance.collection('gifts').doc(widget.giftID).delete();
          print('Document deleted successfully');
        } catch (e) {
          print('Error deleting document: $e');
        }
      }

      if (mounted) {
        showTopSnackBar(
          context,
          'Gift Deleted Successfully!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error during Gift Deletion: $e');
      if (mounted) {
        showTopSnackBar(
          context,
          'Deletion Failed!',
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
                          'Editing Gift',
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
                  "Gift ID: ${widget.giftID}",
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
                      validator: (value) => value == null || value.isEmpty ? 'Please enter the gift name' : null,
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Description',
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter the description' : null,
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      controller: _pointsRequiredController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Points Required',
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter the points required' : null,
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
                    SizedBox(height: 8.h),
                      ElevatedButton(
                            onPressed: _updateGift,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                    SizedBox(height: 3.h),
                    ElevatedButton(
                            onPressed: _deleteGift,
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
                              'Delete Gift',
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
