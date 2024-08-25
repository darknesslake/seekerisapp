import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seekeris/screens/profile_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:seekeris/etc/buildPostForEvery.dart';
// import 'package:seekeris/resources/auth.dart';



class FollowersScreen extends StatefulWidget {
  final String userId; // User ID to display the profile for

  const FollowersScreen({super.key, required this.userId});

  @override
  FollowersScreenState createState() => FollowersScreenState();
}

class FollowersScreenState extends State<FollowersScreen> {

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
    // final authService = Provider.of<Auth>(context, listen: false);
    // final currentUserId = authService.user?.uid;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor:  const Color(0xFF0D1015),
        title: const Text('Followers',
        style: TextStyle(
                color: Colors.white,
                 
                fontFamily: 'Wittgenstein', 
                fontWeight: FontWeight.bold 
                ),),
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<DocumentSnapshot>( // Fetch current user's data to get 'following' list
        stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasError) {
            return Text('Error: ${userSnapshot.error}');
          }

          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            // final following = userData['following'] as List<dynamic>? ?? []; // Get the 'following' list
            final followers = userData['followers'] as List<dynamic>? ?? []; // Get the 'following' list

            return ListView.builder(
            itemCount: followers.length,
            itemBuilder: (context, index) {
              final followerId = followers[index];
              return FutureBuilder<DocumentSnapshot>( 
                // Fetch each follower's data
                future: FirebaseFirestore.instance.collection('users').doc(followerId).get(),
                builder: (context, followerSnapshot) {
                  if (followerSnapshot.hasError) {
                    return Text('Error: ${followerSnapshot.error}');
                  }

                  if (followerSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink(); // Or a placeholder widget while loading
                  }

                  if (followerSnapshot.hasData && followerSnapshot.data!.exists) {
                    final followerData = followerSnapshot.data!.data() as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(followerData['profilePictureUrl'] ?? '../assets/images/default_profile.png'),
                      ),
                      title: Text(followerData['username'] ?? '', style: const TextStyle(color: Colors.white),),
                      subtitle: Text(followerData['displayName'] ?? '', style: const TextStyle(color: Colors.white),),
                      onTap: () {
                        // Get the userId of the tapped user
                        final String userId = followerData['userId'];

                        // Navigate to the user's profile
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(userId: userId),
                          ),
                        );
                      },
                    );
                  } else {
                    return const SizedBox.shrink(); // Or handle the case where the follower's data is not found
                  }
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