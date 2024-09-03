import 'dart:io'; // For File class
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:seekeris/resources/auth.dart';
// import 'package:image_picker/image_picker.dart'; // For image picking

class HeaderEditScreen extends StatefulWidget {
  final Map<String, dynamic> userData; // Receive initial user data
  final String userId; // User ID to display the profile for


  const HeaderEditScreen({super.key, required this.userData, required this.userId}); // Constructor

  @override
  HeaderEditScreenState createState() => HeaderEditScreenState();
}

class HeaderEditScreenState extends State<HeaderEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  Map<String, dynamic>? _userData;

  String? _displayName;
  String? _bio;
  File? _imageFile; // Store the selected image file

  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _genderController;
  String? _usernameError;


  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _nameController = TextEditingController(text: widget.userData['name'] ?? '');
    _usernameController = TextEditingController(text: widget.userData['username'] ?? '');
    _bioController = TextEditingController(text: widget.userData['bio'] ?? '');
    _genderController = TextEditingController(text: widget.userData['gender'] ?? '');
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _genderController.dispose();
    super.dispose();
  }


  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userSnapshot.exists) {
        // final userData = userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _userData = userSnapshot.data() as Map<String, dynamic>;
          // final userData = userSnapshot.data() as Map<String, dynamic>;
          // _username = _userData?['username'];
          // _nickname = userData['displayName'];

          // Fetch follow status
          final followers = _userData?['followers'] as List<dynamic>? ?? [];
          final authProvider = Provider.of<Auth>(context, listen: false);
          final currentUserId = authProvider.user?.uid;
        });
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
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

  // Asynchronous validation function
  Future<void> _validateUsername(String? value) async {
    if (value == null || value.isEmpty) {
      setState(() {
        _usernameError = 'Please enter a username'; 
      });
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: value.trim().toLowerCase())
          .get();

      setState(() {
        _usernameError = querySnapshot.docs.isNotEmpty 
            ? 'Username is already taken'
            : null; 
      });
    } catch (e) {
      print('Error checking username availability: $e');
      setState(() {
        _usernameError = 'An error occurred. Please try again later.';
      });
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

                      Row(
                        children: [
                          const Text('Name', style: TextStyle(color: Colors.white)),
                          const SizedBox(width: 150), // Add some spacing between Text and TextFormField
                          Expanded( // Use Expanded to make TextFormField take available space
                            child: TextFormField(
                              controller: _nameController,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: const InputDecoration(
                                hintText: 'Enter a name',
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Color(0xFF0D1015),
                              ),
                              style: const TextStyle(color: Colors.white),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Name'; 
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10), 

                      Row(
                        children: [
                          const Text('Username', style: TextStyle(color: Colors.white)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _usernameController,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                hintText: 'Enter a username',
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: const Color(0xFF0D1015),
                                errorText: _usernameError, // Display the error message
                              ),
                              style: const TextStyle(color: Colors.white),
                              onChanged: (value) => _validateUsername(value), // Trigger validation on change
                              validator: (value) {
                                // Basic synchronous validation
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a username';
                                }
                                return null; 
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Text('Bio', style: TextStyle(color: Colors.white)),
                          const SizedBox(width: 150), 
                          Expanded(
                            child: TextFormField(
                              controller: _bioController,
                              decoration: const InputDecoration(
                                hintText: 'Enter a Bio',
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Color(0xFF0D1015),
                              ),
                              style: const TextStyle(color: Colors.white),
                              validator: (value) {
                                if (value != _bioController.text) { 
                                  return ''; 
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Text('Choose your gender', style: TextStyle(color: Colors.white)),
                          const SizedBox(width: 150),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _genderController.text.isNotEmpty ? _genderController.text : null, // Set initial value if available
                              decoration: const InputDecoration(
                                hintStyle: TextStyle(color: Colors.white),
                              ),
                              dropdownColor: Colors.black,
                              items: const [
                                DropdownMenuItem(value: 'Male', child: Text('Male', style: TextStyle(color: Colors.white),)),
                                DropdownMenuItem(value: 'Female', child: Text('Female', style: TextStyle(color: Colors.white),)),
                              ],
                              onChanged: (value) {
                                _genderController.text = value ?? ''; // Update the controller when a value is selected
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select your gender';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
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