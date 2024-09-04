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
import 'package:shared_preferences/shared_preferences.dart';


class GenderSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> userData; // Receive initial user data
  final String? initialGender;
  final Function(String) onGenderSelected; 

  const GenderSelectionScreen({
    super.key, required this.userData, 
    // required void Function(String selectedGender) onGenderSelected, String? initialGender,
    this.initialGender, required this.onGenderSelected, 
  });

  @override
  GenderSelectionScreenState createState() => GenderSelectionScreenState();
}

class GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selectedGender;
  late final TextEditingController _genderController;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();


  final ValueNotifier<String?> _selectedGenderNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _loadSelectedGender(); 
    _genderController = TextEditingController(text: widget.userData['selectedGender'] ?? '');

    _selectedGenderNotifier.value = _genderController.text;
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

  // Save the selected gender to SharedPreferences
  Future<void> _saveSelectedGender(String gender) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedGender', gender);

    // try {
    //     final userDocRef = FirebaseFirestore.instance
    //         .collection('users')
    //         .doc(widget.userData['userId']);

    //     // Upload image if selected

    //     // Update other profile data
    //     await userDocRef.update({
    //       'selectedGender': _selectedGender,
    //     });

    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Profile updated successfully!')),
    //     );

    //     Navigator.of(context).pop(); // Navigate back to profile page
    //   } catch (e) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Error updating profile: $e')),
    //     );
    //   }
  }

  // Future<void> _saveSelectedGender(String gender) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('selectedGender', gender);
  //       print('Saved gender: $gender'); // Log the saved gender
  //     } catch (e) {
  //       print('Error saving selected gender: $e'); 
  //     }
  //   }



  Future<void> _saveGenderToFirestore(BuildContext context, String gender) async {
    try {
      final authProvider = Provider.of<Auth>(context, listen: false);
      final currentUserId = authProvider.user?.uid;

      if (currentUserId != null) {
        await FirebaseFirestore.instance
            .collection('users') // Assuming your users collection is named 'users'
            .doc(currentUserId)
            .update({'selectedGender': _selectedGender});

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
            'selectedGender': _selectedGender,
            // 'gender': _genderController.text,
          });

          // Optionally update Firebase Authentication display name

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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Match the image background
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gender',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (_selectedGender != null) {
                try {
                  // 1. Save the selected gender to Firestore (call AuthService method)
                  await context.read<Auth>().saveGenderToFirestore(context, _selectedGender!);

                  // 2. Call the callback to update the gender in the parent widget
                  widget.onGenderSelected(_selectedGender!);

                  // 3. Navigate back to the previous screen
                  Navigator.pop(context, _selectedGender);
                } catch (e) {
                  // Handle errors (e.g., show a SnackBar)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating gender: $e')),
                  );
                }
              }
            },
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: Container( // Add Container for background color
        color: Colors.black,
        child: ListView(
          children: [
            ValueListenableBuilder<String?>(
                valueListenable: _selectedGenderNotifier,
                builder: (context, selectedGender, _) {
                  return Column(
                    children: [
                      const Text('Choose your gender', style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 10),
                      _buildGenderOption('Male', ),
                      _buildGenderOption('Female', ),
                      _buildGenderOption('Custom', ),
                      _buildGenderOption('Prefer not to say', ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(String gender) {
    return RadioListTile<String>(
      title: Text(gender, style: TextStyle(color: Colors.white)),
      value: gender,
      groupValue: _selectedGender,
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
        _saveSelectedGender(value!); // Save the selected gender
      },
      activeColor: Colors.blue, // Set the active color to match the image
    );
  }



}