import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybunnies/adminmodels/countrylist.dart';
import 'package:studybunnies/adminwidgets/top_snack_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Adduser extends StatefulWidget {
  const Adduser({super.key});

  @override
  State<Adduser> createState() => _AdduserState();
}

class _AdduserState extends State<Adduser> {
  final ImagePicker _picker = ImagePicker();
  String? _pickedImagePath;
  String? _selectedCountry;
  String? _selectedRole;
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  // Handle Image Data
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImagePath = pickedFile.path;
      });
    }
  }
  // Show password in text / in asterisk form
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }
  // Check profile picture uploaded by User
  bool _isProfilePictureAdded() {
    return _pickedImagePath != null && _pickedImagePath!.isNotEmpty;
  }
  // Add user data into database
  void _submitForm() async {
    if (_formKey.currentState!.validate() && _isProfilePictureAdded()) {
      final usersCollection = FirebaseFirestore.instance.collection('users');
      final auth = FirebaseAuth.instance;

      print(_emailController.text);
      print(_passwordController.text);

      try {
        UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        String userId = userCredential.user!.uid;

        String profileImageUrl = '';
        if (_pickedImagePath != null) {
          File file = File(_pickedImagePath!);
          TaskSnapshot snapshot = await FirebaseStorage.instance
              .ref('profile_images/$userId')
              .putFile(file);
          profileImageUrl = await snapshot.ref.getDownloadURL();
        }

        DocumentReference docRef = usersCollection.doc(userId);
        await docRef.set({
          'userID': userId,
          'username': _nameController.text,
          'contactnumber': _contactNumberController.text,
          'email': _emailController.text,
          'country': _selectedCountry,
          'password': _passwordController.text,
          'role': _selectedRole,
          'profile_img': profileImageUrl,
        });

        if (mounted) {
          showTopSnackBar(
            context,
            'User Added Successfully!',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        _nameController.clear();
        _contactNumberController.clear();
        _emailController.clear();
        _passwordController.clear();
        setState(() {
          _selectedCountry = null; 
          _selectedRole = null;    
        });
        _pickedImagePath = null;
        }
      } catch (e) {
        if (mounted) {
          showTopSnackBar(
            context,
            'Registered Email, Please Use Another Email !',
            backgroundColor: const Color.fromARGB(255, 246, 77, 65),
            textColor: Colors.white,
          );
        }
      }
    } else {
      if (!_isProfilePictureAdded()) {
        showTopSnackBar(
          context,
          'Please Include a Profile Picture!',
          backgroundColor: const Color.fromARGB(255, 246, 77, 65),
          textColor: Colors.white,
        );
      }
    }
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  @override
  void dispose(){
    _nameController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                        'Adding User',
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
                  CircleAvatar(
                    backgroundImage: _pickedImagePath != null
                        ? FileImage(File(_pickedImagePath!))
                        : const AssetImage('images/addimage.png') as ImageProvider,
                    radius: 12.w,
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
                "User ID: Auto Generated",
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
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter a Name';
                      } else if (value.length <= 2) {
                        return 'Name must be at least 3 Characters Long';
                      } else if (RegExp(r'[^\p{L}\s/]', unicode: true).hasMatch(value)) {
                        return 'Name Contains Invalid Characters';
                      } else if (RegExp(r'\d').hasMatch(value)) {
                        return 'Name Should Not Contain Numbers';
                      }
                      return null;
                      },
                  ),

                  SizedBox(height: 2.h),

                  TextFormField(
                    controller: _contactNumberController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Contact Number',
                    ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter a Contact Number';
                        } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                          return 'Please Enter a Valid Contact Number (Digits Only)';
                        } else if (value.length < 7 || value.length > 15) {
                          return 'Please Enter a Contact Number between 7 and 15 digits';
                        }
                        return null;
                      },
                  ),

                  SizedBox(height: 2.h),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'E-mail',
                    ),
                    validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter an Email Address';
                          } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[cC][oO][mM]$').hasMatch(value)) {
                            return 'Please Enter a Valid Email Address ending with .com';
                          }
                      return null;
                      },
                  ),

                  SizedBox(height: 2.h),

                  DropdownSearch<String>(
                    popupProps: const PopupProps.menu(
                      showSelectedItems: true,
                      showSearchBox: true,
                    ),
                    items: countries,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Country',
                        border: const UnderlineInputBorder(),
                        labelStyle: TextStyle(
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    selectedItem: _selectedCountry,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCountry = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a country';
                      }
                      return null;
                    },
                  ),


                  SizedBox(height: 2.h),

                  Padding(
                    padding: EdgeInsets.only(left: 0.w, right: 0.w),
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            size: 17.sp,
                            color: Colors.grey,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        else if (value.length < 6 || value.length > 20) {
                          return 'Please Include 6 - 20 Characters Only ';
                        }
                        else if (!RegExp(r'[A-Z]').hasMatch(value) || !RegExp(r'[a-z]').hasMatch(value)) {
                          return 'Please Include Upper and Lower Case';
                        }
                         return null;
                      },
                      obscureText: _obscurePassword,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  DropdownSearch<String>(
                    popupProps: const PopupProps.menu(
                      showSelectedItems: true,
                      showSearchBox: false,
                    ),
                    items: const <String>['Student', 'Teacher', 'Admin'],
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Role',
                        border: const UnderlineInputBorder(),
                          labelStyle: TextStyle(
                              fontSize: 12.sp,
                            ),
                      ),
                    ),
                    selectedItem: _selectedRole,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Select a Role';
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 8.h),

                  ElevatedButton(
                    onPressed:_submitForm,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 50), // Ensures the button takes full width
                    ),
                    child: const Text(
                      'Add User',
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
