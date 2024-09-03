// import 'dart:io'; // For File class
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:provider/provider.dart';
// import 'package:seekeris/resources/auth.dart';
import 'package:seekeris/settings_screen/account/password_edit.dart';
import 'package:seekeris/settings_screen/account/privacy_screen.dart';
import 'package:seekeris/settings_screen/account/profile_header_edit.dart';

import '../../resources/auth.dart';
// import 'package:image_picker/image_picker.dart'; // For image picking

class AccountEdit extends StatefulWidget {
  // final String? userId; // User ID to display the profile for
  final Map<String, dynamic> userData; // Receive initial user data
  
  const AccountEdit({super.key, required this.userData}); // Constructor

  @override
  AccountEditState createState() => AccountEditState();
}

class AccountEditState extends State<AccountEdit> {
  Map<String, dynamic>? _userData;  

  @override
  void initState() {
    super.initState();
    _userData = widget.userData; // Initialize _userData from widget
  }
  
  Widget _buildButton(BuildContext context, String label, IconData icon, Widget destination, 
  {Map<String, dynamic>? userData, String? userId}) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
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
    final authProvider = Provider.of<Auth>(context, listen: false);
    final currentUserId = authProvider.user?.uid;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0D1015),
        title: const Text('Account Settings', style: TextStyle(color: Colors.white),),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                  _buildButton(
                    context,
                    'Header',
                    Icons.edit_square,
                    HeaderEditScreen(userData: _userData!, userId: currentUserId!), // Assuming _userData is non-nullable here
                  ),
                  
                  
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                  _buildButton(
                    context,
                    'Privacy', // Consider a more descriptive name for this button
                    Icons.privacy_tip,
                    PrivacyScreen(userData: _userData!), // Assuming userData might be null
                  ),
                  const SizedBox(height: 12),
                  
                  _buildButton(
                    context,
                    'Password and security',
                    Icons.security,
                    // Null check and provide a default empty map if needed
                    PasswordEditScreen(userData: _userData!), 
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

        