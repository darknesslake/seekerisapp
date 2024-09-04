import 'dart:io'; // For File class
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image_picker/image_picker.dart'; // For image picking

class PrivacyScreen extends StatefulWidget {
  final Map<String, dynamic> userData; // Receive initial user data
  
  const PrivacyScreen({super.key, required this.userData}); // Constructor

  @override
  PrivacyScreenState createState() => PrivacyScreenState();
}

class PrivacyScreenState extends State<PrivacyScreen> {
  final _formKey = GlobalKey<FormState>();
  
  bool _isPrivate = false;


  @override
  void initState() {
    super.initState();
    _loadIsPrivate(); // Load the saved value from SharedPreferences
  }

  Future<void> _loadIsPrivate() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPrivate = prefs.getBool('isPrivate') ?? false; // Default to false if not found
    });
  }

  // Save the _isPrivate value to SharedPreferences
  Future<void> _saveIsPrivate(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPrivate', value);
    
    
    try {
        final userDocRef = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userData['userId']);

        // Upload image if selected

        // Update other profile data
        await userDocRef.update({
          'isPrivate': _isPrivate,
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1015),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Profile Edit',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              _saveIsPrivate(_isPrivate);
            },
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.all(10.0),),
            
            
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
                      Switch(
                        // This bool value toggles the switch.
                        value: _isPrivate,
                        activeColor: Colors.red,
                        onChanged: (bool value) {
                          // This is called when the user toggles the switch.
                          setState(() {
                            _isPrivate = !_isPrivate;
                          });
                        },
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