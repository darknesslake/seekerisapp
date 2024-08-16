import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seekeris/resources/auth.dart';
import 'package:flutter/foundation.dart';


class CreatePostScreen extends StatefulWidget {
  final String userId; // User ID to display the profile for

  const CreatePostScreen({super.key, required this.userId});

  @override
  CreatePostScreenState createState() => CreatePostScreenState();
  }

class CreatePostScreenState extends State<CreatePostScreen> {
  Map<String, dynamic>? _userData;
  final TextEditingController _postContentController = TextEditingController();
  bool _isLoading = false; // To show loading indicator
  String? _selectedGame;


  final List<String> _games = ['VALORANT', 'CS 2', 'LoL', 'Dota 2'];


  @override
  void dispose() {
    _postContentController.dispose();
    super.dispose();
  }

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
          _userData = userSnapshot.data() as Map<String, dynamic>;
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
  

  Future<void> createPost(BuildContext context, String content, String? selectedGame) async {
    try {
      final authService = Provider.of<Auth>(context, listen: false); // Get the Auth instance
      final currentUser = authService.user;

      if (currentUser == null) {
        throw Exception('User not logged in.');
      }

      // Get a reference to the 'posts' collection
      final CollectionReference postsCollection =
          FirebaseFirestore.instance.collection('posts');

      // Create a new document with an auto-generated ID
      await postsCollection.add({
        'userId': currentUser.uid,
        'userName': _userData?['username'] ?? 'Anonymous', // Get username or use a default
        'userImageUrl': currentUser.photoURL ?? '', // Get profile picture URL or empty string
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'commentsCount': 0,
        'game': selectedGame,
        // Add other fields as needed (e.g., media URLs)
      });

      // Optionally, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );

    } on FirebaseException catch (e) {
      // Handle Firestore errors
      print('Firestore Error: ${e.code} - ${e.message}');
      // Show a SnackBar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating post: ${e.message}')),
      );
    } catch (e) {
      // Handle other exceptions
      print('Error: $e');
      // Show a general error SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while creating the post.')),
      );
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  Color(0xFF0D1015),
        title: const Text('Create Post',
        style: TextStyle(
                color: Colors.white,
                 
                fontFamily: 'Wittgenstein', 
                fontWeight: FontWeight.bold 
                ),),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedGame,

              decoration: const InputDecoration(labelText: 'Select Game', labelStyle: TextStyle(color: Colors.white),),
              // style: TextStyle(color: Colors.red),
              items: _games.map((game) {
                return DropdownMenuItem<String>(
                  
                  value: game,
                  child: Text(game, style: TextStyle(color: Colors.black),),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGame = value;
                });
                
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a game';
                }
                return null;
              },
              selectedItemBuilder: (BuildContext context) {
                return _games.map((String value) {
                  return Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white, // Set the color of the selected item text
                    ),
                  );
                }).toList();
              },
            ),
            TextField(
              style: TextStyle(color: Colors.white),
              controller: _postContentController,
              decoration: const InputDecoration(
                hintText: 'What\'s on your mind?',hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              maxLines: null, // Allow multiple lines
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : () async { // Disable button while loading
                if (_postContentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter some content', style: TextStyle(color: Colors.white),)),
                  );
                  return;
                }

                setState(() {
                  _isLoading = true;
                });

                try {
                  await createPost(context, _postContentController.text, _selectedGame);
                  // Print "Post added" instead of navigating back
                  print('Post added'); 
                } catch (e) {
                  // Error handling is already included in the createPost function
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              child: _isLoading
                  ? const CircularProgressIndicator() // Show loading indicator
                  : const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}

class CurrentPostProvider with ChangeNotifier {
  String? _currentPostId;

  String? get currentPostId => _currentPostId;

  void setCurrentPostId(String postId) {
    _currentPostId = postId;
    notifyListeners();
  }
}