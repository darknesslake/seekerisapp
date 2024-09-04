import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seekeris/etc/buildPostForEvery.dart';
import 'package:seekeris/resources/auth.dart';

class FeedScreen extends StatefulWidget {
  final String userId; // User ID to display the profile for

  const FeedScreen({super.key, required this.userId});

  @override
  FeedScreenState createState() => FeedScreenState();
  }

class FeedScreenState extends State<FeedScreen> {

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch the user's profile data on initialization
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userSnapshot.exists) {
        setState(() {
        });
      } else {
        // Handle the case where the user document doesn't exist
        throw Exception('User not found');
      }
    } catch (e) {
      // Handle errors, e.g., show a SnackBar
      print('Error fetching user data: $e');
    }
  }
  


  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<Auth>(context, listen: false);
    final currentUserId = authService.user?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:  const Color(0xFF0D1015),
        title: const Text('Feed',
        style: TextStyle(
                color: Colors.white,
                 
                fontFamily: 'Wittgenstein', 
                fontWeight: FontWeight.bold 
                ),),
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<DocumentSnapshot>( // Fetch current user's data to get 'following' list
        stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasError) {
            return Text('Error: ${userSnapshot.error}');
          }

          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final following = userData['following'] as List<dynamic>? ?? []; // Get the 'following' list

            if (following.isEmpty) {
              return const Center(child: Text('You are not following anyone yet.', style: TextStyle(color: Colors.white),));
            }

            return StreamBuilder<QuerySnapshot>( // Fetch posts from followed users
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('userId', whereIn: following) // Filter by followed users
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, postsSnapshot) {
                if (postsSnapshot.hasError) {
                  return const Text('Error loading posts');
                }

                if (postsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = postsSnapshot.data!.docs;

                if (posts.isEmpty) {
                  return const Center(child: Text('No posts from your friends yet.', style: TextStyle(color: Colors.white),));
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final postData = posts[index].data() as Map<String, dynamic>;
                    postData['postId'] = posts[index].id;
                    return BuildPostForEvery(postData: postData,);
                  },
                );
              },
            );
          } else {
            return const Text('User not found');
          }
        },
      ),
    );
  }
}