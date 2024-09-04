import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget { 
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.exists) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return _buildProfileContent(userData);
          } else {
            return const Center(child: Text('User not found'));
          }
        },
      ),
    );
  }

  Widget _buildProfileContent(Map<String, dynamic> userData) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar( // Display profile picture (you might need to adjust this)
            radius: 50,
            // backgroundImage: NetworkImage(userData['profilePictureUrl'] ?? ''),
          ),
          const SizedBox(height: 16),
          Text(
            userData['displayName'] ?? 'User Name',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('@${userData['username'] ?? ''}'), // Display username if available
          const SizedBox(height: 12),
          if (userData['bio'] != null)
            Text(userData['bio']),
        ],
      ),
    );
  }
}
