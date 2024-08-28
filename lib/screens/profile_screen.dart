// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:provider/provider.dart';
import 'package:seekeris/etc/repost_widget.dart';
import 'package:seekeris/etc/createpost_screen.dart';

import '../resources/auth.dart';
import 'package:intl/intl.dart';
import 'package:seekeris/profile_page/games_screen.dart';
// import 'package:seekeris/profile_page/ProfileCreation.dart';
import 'package:seekeris/settings_screen/ProfileEdition.dart';
import 'package:seekeris/settings_screen/settings_screen.dart';
// import 'package:seekeris/profile_page/favorite_screen.dart';

import '../profile_page/follows_screen.dart';
import '../profile_page/followers_screen.dart';




class ProfileScreen extends StatefulWidget {
  final String userId; // User ID to display the profile for

  const ProfileScreen({super.key, required this.userId});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  // Store fetched user data
  Map<String, dynamic>? _userData;
  
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  bool _isFollowing = false;
  // String? _username; 

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
          _isFollowing = followers.contains(currentUserId);
        });
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Widget _buildProfileActions(BuildContext context, Map<String, dynamic> userData, String? currentUserId) {
    final authProvider = Provider.of<Auth>(context, listen: false);
    final currentUserId = authProvider.user?.uid;
  
    return Column(  
      children: [
        if (userData['userId'] != currentUserId)
          ElevatedButton(
            onPressed: () async {
              try {
                if (_isFollowing) {
                  // Unfollow logic
                  await _unfollowUser(currentUserId!, userData['userId']);
                } else {
                  // Follow logic
                  await _followUser(currentUserId!, userData['userId']);
                }

                setState(() {
                  _isFollowing = !_isFollowing;
                });
              } catch (e) {
                // Handle errors (e.g., show a SnackBar)
                print('Error following/unfollowing user: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFollowing ? Colors.grey[400] : Colors.blue,
            ),
            child: Text(_isFollowing ? 'Unfollow' : 'Follow'),
          ),
          // if (userData['userId'] == currentUserId)
          //   ElevatedButton(
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => ProfileEditScreen(userData: userData),
          //         ),
          //       );
          //     },
          //     child: const Text('Edit Profile'),
          //   ),
        ],
      );
  }



  // Function to follow a user
  Future<void> _followUser(String currentUserId, String targetUserId) async {
    final authProvider = Provider.of<Auth>(context, listen: false);
    final currentUserId = authProvider.user?.uid;
  
    if (currentUserId == targetUserId) { // Prevent self-follow
    return; 
  }
    // 1. Add targetUserId to current user's 'following' array
    await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
      'following': FieldValue.arrayUnion([targetUserId]),
    });

    // 2. Add currentUserId to target user's 'followers' array
    await FirebaseFirestore.instance.collection('users').doc(targetUserId).update({
      'followers': FieldValue.arrayUnion([currentUserId]),
    });
  }

  // Function to unfollow a user
  Future<void> _unfollowUser(String currentUserId, String targetUserId) async {
    final authProvider = Provider.of<Auth>(context, listen: false);
    final currentUserId = authProvider.user?.uid;
  
    if (currentUserId == targetUserId) { // Prevent self-unfollow (redundant but good practice)
      return;
    }

    // 1. Remove targetUserId from current user's 'following' array
    await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
      'following': FieldValue.arrayRemove([targetUserId]),
    });

    // 2. Remove currentUserId from target user's 'followers' array
    await FirebaseFirestore.instance.collection('users').doc(targetUserId).update({
      'followers': FieldValue.arrayRemove([currentUserId]),
    });
  }




  // void _menuOpen(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //     borderRadius: BorderRadius.only(
  //       topLeft: Radius.circular(20.0), 
  //       topRight: Radius.circular(20.0), 
  //     ),),
  //     builder: (BuildContext context) {
  //       return Container(
          
  //         color: const Color.fromARGB(255, 31, 37, 47),
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: <Widget>[

  //             ListTile(
  //               leading: const Icon(Icons.favorite, color: Colors.white,),
  //               title: const Text('Favorites', style: TextStyle(color: Colors.white),),
  //               onTap: () {
  //                 Navigator.of(context).pop(); // Close the bottom sheet
  //                 Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FavoriteScreen()));
  //               },
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.settings, color: Colors.white,),
  //               title: const Text('Settings', style: TextStyle(color: Colors.white),),
  //               onTap: () {
  //                 Navigator.of(context).pop(); // Close the bottom sheet
  //                 Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  //               },
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.logout, color: Colors.white,),
  //               title: const Text('Logout', style: TextStyle(color: Colors.white),),
  //               onTap: () async {
  //                 Navigator.of(context).pop(); // Close the menu before logging out
  //                 try {
  //                   await Provider.of<Auth>(context, listen: false).logout();
  //                   Navigator.of(context).pushReplacementNamed('/login'); // Use pushReplacementNamed for logging out
  //                 } catch (e) {
  //                   // Handle any logout errors here (e.g., show a Snackbar)
  //                   print('Logout error: $e');
  //                 }
  //               },
  //             ),
  //             // Add more menu items as needed...
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic>? userData) {
    if (userData == null) {
      return const Center(
        child: Text('User not found'),
      );
    }

    final authProvider = Provider.of<Auth>(context, listen: false);
    final currentUserId = authProvider.user?.uid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 31, 37, 47),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProfileImage(userData),
          const SizedBox(width: 20),
          Expanded( // This will make the profile info column take up the remaining space
            child: _buildProfileInfo(userData),
          ),
          const SizedBox(width: 16),
          _buildProfileActions(context, userData, currentUserId!), // Pass the current user ID
        ],
      ),
    );
  }

  Widget _buildProfileImage(Map<String, dynamic> userData) {
    return CircleAvatar(
      radius: 64,
      backgroundColor: Colors.grey,
      backgroundImage: CachedNetworkImageProvider(
        userData['profilePictureUrl'] ?? 'assets/images/default_profile.png',
      ),
    );
  }

  Widget _buildProfileInfo(Map<String, dynamic> userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userData['displayName'] ?? 'User Name',
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        // const SizedBox(height: 8),
        // if (userData['username'] != null) // Display username only if it's available
        //   Text(
        //     '@${userData['username']}',
        //     style: TextStyle(color: Colors.grey[400], fontSize: 16),
        //   ),
        const SizedBox(height: 12),
        if (userData['bio'] != null)
          Text(
            userData['bio'],
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
      ],
    );
  }


  // 1. Build Profile Menu (Games, Friends, Follows)
  Widget _buildProfileMenu(BuildContext context, Map<String, dynamic> userData) {
    final authProvider = Provider.of<Auth>(context, listen: false);
    final currentUserId = authProvider.user?.uid; 

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 31, 37, 47),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
          children: [
            _buildMenuButton(context, 'Games', Icons.games_outlined, const GamesScreen()),
            if (currentUserId != null) // Conditionally add the FollowersScreen button
            _buildMenuButton(
              context, 
              'Followers', 
              Icons.people_outlined, 
              FollowersScreen(userId: currentUserId), // Pass the non-null currentUserId
            ),
          if (currentUserId != null) // Conditionally add the FollowsScreen button
            _buildMenuButton(
              context,
              'Following',
              Icons.person_add_alt_1_outlined,
              FollowsScreen(userId: currentUserId), // Pass the non-null currentUserId
            ),
          ],
        ),
      ),
    );
  }

  // 2. Reusable Function to Build Menu Button
  Widget _buildMenuButton(
      BuildContext context, String label, IconData icon, Widget destination) {
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






  // 3. Build Profile Content (Posts, etc.)
  Widget _buildProfileContent(Map<String, dynamic> userData) {
    // final authProvider = Provider.of<Auth>(context, listen: false); // Get AuthService
    // final currentUserId = authProvider.user?.uid; // Get current user's ID

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 31, 37, 47),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .where('userId', isEqualTo: userData['userId']) // Make sure currentUserId is not null
              .orderBy('timestamp', descending: true) 
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // return Text('Error loading posts: ${snapshot.error}', style: TextStyle(color: Colors.white),); // Display the error message
            print(snapshot.error);
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator()); 
            }


          final posts = snapshot.data!.docs;

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final postData = posts[index].data() as Map<String, dynamic>;
              postData['postId'] = posts[index].id; // Add the document ID to postData
              return _buildPostWidget(postData); 
            },
          );
        },
      ),
    );
  }

  // Function to delete the post from Firestore
  Future<void> _deletePost(BuildContext context, String postId) async {
    try {
      // Set the currentPostId in the provider before deleting
      Provider.of<CurrentPostProvider>(context, listen: false)
        .setCurrentPostId(postId);

      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();

      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Post deleted successfully!')),
      );
    } catch (e) {
      print('Error deleting post: $e');
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Error deleting post: $e')),
      );
    }
  }


  
  Future<void> _showDeleteConfirmationDialog(BuildContext context, String postId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deletePost(context, postId);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }




  // Helper function to format the timestamp
  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp.toDate());

    if (difference.inDays > 0) {
      return DateFormat('MMM d, yyyy').format(timestamp.toDate());
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _navigateToProfile(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userId: userId),
      ),
    );
  }
  
  Widget _buildPostWidget(Map<String, dynamic> postData) {
    // final String userImageUrl = postData['userImageUrl'] ?? '';
    final String userName = postData['userName'] ?? 'Unknown User';
    final String content = postData['content'] ?? '';
    final Timestamp timestamp = postData['timestamp'];
    final int likesCount = postData['likesCount'] ?? 0;
    final int commentsCount = postData['commentsCount'] ?? 0;
    // final String selectedGame = postData['selectedGame'] ?? 'Not choose';
    // final String postId = postData.id; // Get the document ID as postId
    final authProvider = Provider.of<Auth>(context, listen: false); // Get AuthService
    final currentUserId = authProvider.user?.uid; 

    // final String postId = postData['postId']; // Get the document ID as postId

    return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(children: [
            // User Info Row
            Row(
              children: [
                // _buildProfileImage(_userData!), // Function to build the profile image
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                    GestureDetector( // Make username tappable
                      onTap: () {
                        // Navigate to the original poster's profile
                        _navigateToProfile(context, postData[
                          'originalPostUserId'
                        ]);
                      },
                      child: Text(
                        postData['isRepost'] == true 
                          ? postData['whoRepost'] ?? 'nnц76' : userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    const SizedBox(width: 30),
                    Text(
                      postData['game'] != null ? '${postData['game']}' : 'Uncategorized', // Using a ternary operator
                    style: const TextStyle(fontSize: 12, fontFamily: 'Wittgenstein',),),
                    
                    const SizedBox(width: 20),
                    
                    
                    ],),
                    Text(
                      _formatTimestamp(timestamp), 
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            const Spacer(),
            if (postData['userId'] == currentUserId)
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.delete, size: 20,),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, postData['postId']); 
                          },
                        ),
                      ),
            ],),
            const SizedBox(height: 10),

            // Post Content
            Text(content),

            // Optional: Image or Video display if your posts have media
            if (postData['imageUrl'] != null)
              CachedNetworkImage(imageUrl: postData['imageUrl']),
            // Similarly, handle video display if needed

            const SizedBox(height: 10),

            
            // const SizedBox(height: 10),


            // Likes and Comments Row
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {
                    // TODO: Implement like functionality
                  },
                ),
                Text('$likesCount'),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () {
                    // TODO: Implement comment functionality
                  },
                ),
                Text('$commentsCount'),
                const SizedBox(width: 20),

                // const SizedBox(width: 20), // Add some spacing

              // Repost button (show only if it's not the current user's post)
                if (postData['userId'] != currentUserId)
                  RepostWidget(postData: postData),
                const SizedBox(width: 20),

                if (postData['isRepost'] == true) // Check if it's a repost
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.repeat, size: 16, color: Colors.grey[600]), // Repost icon
                        const SizedBox(width: 5),
                        Text(
                          'Reposted by ${postData['userName'] ?? 'Unknown User'}', // Main user's name
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                    ],
                  ),
                ),

              ],
              
            ),
            
            
            ],
          ),
        ),
    );
  }





@override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context, listen: false);
    final currentUserId = authProvider.user?.uid; 

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color(0xFF0D1015),
          title: FutureBuilder<DocumentSnapshot>( 
            future: FirebaseFirestore.instance.collection('users').doc(widget.userId).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Loading...', style: TextStyle(color: Colors.white),);
              } else if (snapshot.hasError) {
                return const Text('Error loading username');
              } else {
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                return Text(
                  userData['username'] ?? 'User Profile', 
                  style: const TextStyle(color: Colors.white, fontFamily: 'Wittgenstein', fontWeight: FontWeight.bold),
                );
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu_outlined, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(userId: currentUserId,),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: (_userData != null)
                ? Column( // Wrap the body content in a Column if userData is not null
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildProfileHeader(context, _userData!),
                      const SizedBox(height: 4),
                      _buildProfileMenu(context, _userData!),
                      const SizedBox(height: 4),
                      _buildProfileContent(_userData!),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
  
}

class CurrentUserProvider with ChangeNotifier {
  String? _currentUserId;

  String? get currentUserId => _currentUserId;

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }
}
