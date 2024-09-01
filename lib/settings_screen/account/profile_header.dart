import 'dart:io'; // For File class
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart'; // For image picking

class HeaderEditScreen extends StatefulWidget {
  final Map<String, dynamic> userData; // Receive initial user data
  
  const HeaderEditScreen({super.key, required this.userData}); // Constructor

  @override
  HeaderEditScreenState createState() => HeaderEditScreenState();
}

class HeaderEditScreenState extends State<HeaderEditScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _displayName;
  String? _bio;
  File? _imageFile; // Store the selected image file

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _genderController = TextEditingController();

  // ... (your other existing fields and methods)


  @override
  void initState() {
    super.initState();
    _displayName = widget.userData['displayName']; // Initialize fields from userData
    _bio = widget.userData['bio'];
  }

  // Future<void> _pickImage() async {
  //   final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _imageFile = File(pickedFile.path);
  //     });
  //   }
  // }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      try {
        final userDocRef = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userData['userId']);

        // Upload image if selected
        if (_imageFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_pictures/${widget.userData['userId']}.jpg');
          await storageRef.putFile(_imageFile!);
          final downloadUrl = await storageRef.getDownloadURL();
          await userDocRef.update({'profilePictureUrl': downloadUrl});
        }

        // Update other profile data
        await userDocRef.update({
          'displayName': _displayName,
          'bio': _bio,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );

        Navigator.of(context).pop(); // Navigate back to profile page
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1015),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Edit profile', 
          style: TextStyle(
            color: Colors.white
            ),
          ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.all(10.0),),
            Container( 
            width: double.infinity,
            // height: double.infinity,
            padding: const EdgeInsets.all(20.0), // Add padding
            decoration: BoxDecoration( // Add some decoration
              color: const Color(0xFF0D1015), // Background color
              borderRadius: BorderRadius.circular(10.0), // Rounded corners
            ),
            child:  const Column( 
              crossAxisAlignment: CrossAxisAlignment
              .start,

              children: [
                Text('Profile picture', 
                  style: TextStyle(
                    color: Colors.white, 
                    fontFamily: 'Merriweather', 
                    fontSize: 30, 
                    // fontWeight: FontWeight.bold
                    ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            
            Container( 
                width: double.infinity,
                padding: const EdgeInsets.all(20.0), // Add padding
                decoration: BoxDecoration( // Add some decoration
                  color: const Color(0xFF0D1015), // Background color
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                ),
                
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child:  Column( 
                    // crossAxisAlignment: CrossAxisAlignment
                    // .start,

                    children: [

                    const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Add name', 
                          hintStyle: TextStyle(
                            color: Colors.white
                            )
                          ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your current password';
                          }
                          return null;
                          },
                      ),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username', 
                          hintStyle: TextStyle(
                            color: Colors.white
                            )
                          ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                          },
                      ),
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                          labelText: 'Add bio', 
                          hintStyle: TextStyle(
                            color: Colors.white
                            )
                          ),
                        obscureText: true,
                        validator: (value) {
                          if (value != _bioController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _genderController,
                        decoration: const InputDecoration(
                          labelText: 'Choose your gender', 
                          hintStyle: TextStyle(
                            color: Colors.white
                            )
                          ),
                        obscureText: true,
                        validator: (value) {
                          if (value != _genderController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        child: const Text(
                          'Save', 
                          style: TextStyle(
                            color: Colors.black
                            )
                          ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}