// File: lib/build_post.dart 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:seekeris/etc/repost_widget.dart';
import 'package:seekeris/resources/auth.dart';
import 'package:seekeris/screens/profile_screen.dart';

class BuildPostForEvery extends StatelessWidget {
  final Map<String, dynamic> postData;

  const BuildPostForEvery({super.key, required this.postData});

  @override
  Widget build(BuildContext context) {
    final String userImageUrl = postData['userImageUrl'] ?? '';
    final String userName = postData['userName'] ?? 'Unknown User';
    final String content = postData['content'] ?? '';
    final Timestamp timestamp = postData['timestamp'];
    final int likesCount = postData['likesCount'] ?? 0;
    final int commentsCount = postData['commentsCount'] ?? 0;
    final authProvider = Provider.of<Auth>(context, listen: false); // Get AuthService
    final currentUserId = authProvider.user?.uid; 


    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Row
            Row(
              children: [
                _buildProfileImage(userImageUrl),
                const SizedBox(width: 10),
                Expanded( // Use Expanded to allow the Column to take up available space
      child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                    GestureDetector( // Make username tappable
                      onTap: () {
                        // Navigate to the original poster's profile
                        _navigateToProfile(context, postData['userId']);
                      },
                      child: Text(
                        userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 30),
                    Text(
                      postData['game'] != null ? '${postData['game']}' : 'Uncategorized', // Using a ternary operator
                    style: const TextStyle(fontSize: 12, fontFamily: 'Wittgenstein',),),
                    ],),
                    Text(
                      _formatTimestamp(timestamp), 
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),),
              ],
            ),
            const SizedBox(height: 10),

            // Post Content
            Text(content),

            // Optional: Image or Video display if your posts have media
            if (postData['imageUrl'] != null)
              CachedNetworkImage(imageUrl: postData['imageUrl']),
            // Similarly, handle video display if needed

            const SizedBox(height: 10),

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
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () {
                    // TODO: Implement comment functionality
                  },
                ),
                Text('$commentsCount'),
                
                const SizedBox(width: 12),
                if (postData['userId'] != currentUserId)
                  RepostWidget(postData: postData),
                
                const SizedBox(width: 12),            
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

  // Helper function to build the profile image
  Widget _buildProfileImage(String imageUrl) {
    return CircleAvatar(
      backgroundImage: CachedNetworkImageProvider(imageUrl),
    );
  }

  void _navigateToProfile(BuildContext context, String userId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfileScreen(userId: userId),
    ),
  );
}
}
