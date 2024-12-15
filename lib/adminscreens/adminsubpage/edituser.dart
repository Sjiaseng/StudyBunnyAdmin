import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studybunnies/adminmodels/countrylist.dart';
import 'package:studybunnies/adminwidgets/top_snack_bar.dart';

class Edituser extends StatefulWidget {
  final String userID; 

  const Edituser({required this.userID, super.key});

  @override
  State<Edituser> createState() => _EdituserState();
}

class _EdituserState extends State<Edituser> {
  final ImagePicker _picker = ImagePicker();
  String? _pickedImagePath;
  String? _selectedCountry;
  String? _selectedRole;
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userID).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          _nameController.text = data['username'];
          _contactNumberController.text = data['contactnumber'];
          _emailController.text = data['email'];
          _passwordController.text = data['password'];
          _selectedCountry = data['country'];
          _selectedRole = data['role'];
          _pickedImagePath = data['profile_img'];
          _obscurePassword = true; 
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImagePath = pickedFile.path;
      });
    }
  }
  // Keep the password visible / invisible as text
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }
  // check is the profile picture included
  bool _isProfilePictureAdded() {
    return _pickedImagePath != null && _pickedImagePath!.isNotEmpty;
  }
  // submit / update form data
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final usersCollection = FirebaseFirestore.instance.collection('users');

      try {
        String profileImageUrl = '';

        if (_pickedImagePath != null && !_pickedImagePath!.startsWith('http')) {
          File file = File(_pickedImagePath!);

          if (!file.existsSync()) {
            throw Exception('File does not exist at path: ${file.path}');
          }
          // update the image set the name based on their userID 
          TaskSnapshot snapshot = await FirebaseStorage.instance
              .ref('profile_images/${widget.userID}')
              .putFile(file);
          profileImageUrl = await snapshot.ref.getDownloadURL();
        } else {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userID).get();
          if (userDoc.exists) {
            final data = userDoc.data()!;
            profileImageUrl = data['profile_img'] ?? ''; 
          }
        }
        // updating records based on userID
        DocumentReference docRef = usersCollection.doc(widget.userID);
        await docRef.update({
          'username': _nameController.text,
          'contactnumber': _contactNumberController.text,
          'country': _selectedCountry,
          'role': _selectedRole,
          'email': _emailController.text,
          'password': _passwordController.text,
          'profile_img': profileImageUrl,
        });

        if (mounted) {
          showTopSnackBar(
            context,
            'User Updated Successfully!',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
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

  // delete user function to remove user data from users doc
 Future<void> _deleteUser() async {
  try {
    // Fetch user document from Firestore
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userID).get();
    if (userDoc.exists) {
      final data = userDoc.data()!;
      final imagePath = data['profile_img'];

      // Delete profile image if it exists
      if (imagePath != null && imagePath.isNotEmpty) {
        final storageRef = FirebaseStorage.instance.refFromURL(imagePath);
        await storageRef.delete();
      }

      // Delete user document from Firestore
      await FirebaseFirestore.instance.collection('users').doc(widget.userID).delete();

      // Show success message and pop the context if mounted
      if (mounted) {
        showTopSnackBar(
          context,
          'User Deleted Successfully!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pop(context);
      }
    } else {
      // Handle case where user document does not exist
      print('User document not found.');
      if (mounted) {
        showTopSnackBar(
          context,
          'User not found!',
          backgroundColor: const Color.fromARGB(255, 246, 77, 65),
          textColor: Colors.white,
        );
      }
    }
  } catch (e) {
    // Handle errors and show failure message if mounted
    print('Error during user deletion: $e');
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
  void dispose() {
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
                        'Editing User',
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
                    backgroundImage: _pickedImagePath != null && _pickedImagePath != ""
                        ? (_pickedImagePath!.contains('http') 
                            ? NetworkImage(_pickedImagePath!) 
                            : FileImage(File(_pickedImagePath!)) as ImageProvider)
                        : const AssetImage('images/profile.webp'),
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
                          onPressed: _selectedRole == 'Admin' ? null : _pickImage,
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
                "User ID: ${widget.userID}",
                style: TextStyle(
                  fontSize: 8.sp,
                  color: Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                  TextFormField(
                    controller: _nameController,
                    enabled: _selectedRole == 'Admin' ? false : true,
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
                      enabled: _selectedRole == 'Admin' ? false : true,
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
                    enabled: false,
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
                        enabled: _selectedRole == 'Admin' ? false : true,
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
                        enabled: false,
                        controller: _passwordController,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'Password',
                          enabled: false,
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
                      items: _selectedRole != 'Admin' ? <String>['Student', 'Teacher'] :  <String>['Student', 'Teacher', 'Admin'],
                      enabled: _selectedRole != 'Admin', 
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'Role',
                          labelStyle: TextStyle(
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      selectedItem: _selectedRole,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedRole = newValue;
                          });
                        }
                      },
                      popupProps: PopupProps.menu(
                        showSearchBox: false,
                        itemBuilder: (context, item, isSelected) {
                          // Disable 'Admin' item in the dropdown
                          return ListTile(
                            title: Text(item),
                          );
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a role';
                        }
                        return null;
                      },
                    ),


                    SizedBox(height: 4.h),

                    ElevatedButton(
                      onPressed: _selectedRole == 'Admin' ? null : _submitForm,
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
                    SizedBox(height: 2.h),

                    ElevatedButton(
                      onPressed: _deleteUser,
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
                        'Delete User',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
