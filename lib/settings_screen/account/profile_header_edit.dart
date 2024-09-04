import 'dart:io'; // For File class
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:seekeris/resources/auth.dart';
import 'package:seekeris/settings_screen/account/gender_select.dart';
import 'package:shared_preferences/shared_preferences.dart';


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


  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _genderController;
  String? _usernameError;
  String? _selectedGender;

  final ValueNotifier<String?> _selectedGenderNotifier = ValueNotifier<String?>(null);
  

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _nameController = TextEditingController(text: widget.userData['displayName'] ?? '');
    _usernameController = TextEditingController(text: widget.userData['username'] ?? '');
    _bioController = TextEditingController(text: widget.userData['bio'] ?? '');
    _genderController = TextEditingController(text: widget.userData['gender'] ?? '');

    _selectedGenderNotifier.value = _genderController.text;
    _loadSelectedGender();
    
  }


  @override
  void dispose() {
    _selectedGenderNotifier.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _selectedGenderNotifier.dispose(); //
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

  Future<void> _loadSelectedGender() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGender = prefs.getString('selectedGender');
    setState(() {
      _selectedGender = savedGender;
      _genderController.text = savedGender ?? '';
      _selectedGenderNotifier.value = savedGender;
    });
  }
  
  // Future<void> _saveSelectedGender(String gender) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('selectedGender', gender);
  // }

  void _handleGenderSelection(String selectedGender) {
    setState(() {
      _genderController.text = selectedGender;
    });
    _selectedGenderNotifier.value = selectedGender; // Update the ValueNotifier

    _saveGenderToFirestore(context, selectedGender);
  }


  Future<void> _saveGenderToFirestore(BuildContext context, String gender) async {
    try {
      final authProvider = Provider.of<Auth>(context, listen: false);
      final currentUserId = authProvider.user?.uid;

      if (currentUserId != null) {
        await FirebaseFirestore.instance
            .collection('users') // Assuming your users collection is named 'users'
            .doc(currentUserId)
            .update({'selectedGender': gender});

        print('Gender updated successfully in Firestore');
      } else {
        // User is not logged in, handle this case (e.g., show an error message)
        throw Exception('User not logged in.');
      }
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      print('Firebase Error updating gender: ${e.code} - ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating gender: ${e.message}')),
      );
    } catch (e) {
      // Handle other unexpected errors
      print('Unexpected error updating gender: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while updating your gender.')),
      );
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

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = Provider.of<Auth>(context, listen: false);
        final currentUserId = authProvider.user?.uid;

        if (currentUserId != null) {
          // Update Firestore document
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .update({
            'displayName': _nameController.text,
            'username': _usernameController.text,
            'bio': _bioController.text,
            // 'selectedGender': _selectedGender,
            // 'gender': _genderController.text,
          });

          // Optionally update Firebase Authentication display name
        await authProvider.user?.updateDisplayName(_nameController.text);

        // Show success message
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );

        Navigator.pop(context); 
      } else {
        // Handle the case where the user is not logged in
        throw Exception('User not logged in.');
      }
    } on FirebaseException catch (e) {
      // Handle specific Firebase errors
      print('Firebase Error: ${e.code} - ${e.message}'); // Log the error for debugging
      String errorMessage = 'Error updating profile.';
      switch (e.code) {
        case 'permission-denied':
          errorMessage = 'You do not have permission to update this profile.';
          break;
        case 'not-found':
          errorMessage = 'User document not found.';
          break;
        // Add more cases for other potential Firebase errors
      }
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Handle other general exceptions
      print('Unexpected error: $e'); // Log the error for debugging
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    }
  }
}

  Widget _buildButton(BuildContext context, String label, IconData icon, 
                    {Widget? destination, VoidCallback? onPressed}) {
  return ElevatedButton.icon(
    onPressed: onPressed ?? () {
      if (destination != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      }
    },
      icon: Icon(icon, color: Colors.white),
      label: Text(label,
          style: const TextStyle(color: Colors.white, fontFamily: 'Merriweather')),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
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
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1015),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Profile picture', 
                      style: TextStyle(
                        color: Colors.white, 
                        fontFamily: 'Merriweather', 
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center( // Center the image and buttons
                      child: Column(
                        children: [
                          
                        ],
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

                      ValueListenableBuilder<String?>(
                        valueListenable: _selectedGenderNotifier,
                        builder: (context, selectedGender, _) {
                          return Row(
                            children: [
                              const Text('Choose your gender',
                                  style: TextStyle(color: Colors.white)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildButton(
                                  context,
                                  selectedGender ?? 'Select Gender',
                                  Icons.person,
                                  onPressed: () async {
                                    final selectedGender = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GenderSelectionScreen(
                                          initialGender: _selectedGenderNotifier.value, 
                                          onGenderSelected: _handleGenderSelection, userData: _userData!, 
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),


                  //     ValueListenableBuilder<String?>(
                  //       valueListenable: _selectedGenderNotifier,
                  //       builder: (context, selectedGender, _) {
                  //         return Row(
                  //           children: [
                  //         const Text('Choose your gender', style: TextStyle(color: Colors.white)),
                  //         const SizedBox(width: 10),
                  //         Expanded(
                  //           child: SegmentedButton<String>(
                  //             segments: const <ButtonSegment<String>>[
                  //               ButtonSegment<String>(value: 'Male', label: Text('Male',
                  //               style: TextStyle(color: Colors.white),
                  //               )),
                  //               ButtonSegment<String>(value: 'Female', label: Text('Female',
                  //               style: TextStyle(color: Colors.white),

                  //               )),
                  //               ButtonSegment<String>(value: 'Custom', label: Text('Custom',
                  //               style: TextStyle(color: Colors.white),
                  //               )),
                  //               ButtonSegment<String>(
                  //                 value: 'Prefer not to say',
                  //                 label: Text('Prefer not to say',
                  //                 style: TextStyle(color: Colors.white),
                  //                 ),
                  //               ),
                  //             ],
                  //             selected: {_selectedGender!},
                  //             onSelectionChanged: (Set<String> newSelection) {
                  //               if (newSelection.isNotEmpty) {
                  //                 final newGender = newSelection.first;
                  //                 setState(() {
                  //                   _selectedGender = newGender;
                  //                   _genderController.text = newGender;  // Update the controller's text here
                  //                 });
                  //                 _saveSelectedGender(newGender); 
                  //               }
                  //             },
                  //           ),
                  //         ),
                     

                      
                  //   ],);},
                  // ),
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
                ],      ),
          ),
          ),),
          ],
        ),
      ),
    );
  }
  
}



