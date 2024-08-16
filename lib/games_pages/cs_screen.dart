import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seekeris/etc/buildPostForEvery.dart';

// ... (Other imports you might need, like your post widget)

class CounterStrikeScreen extends StatefulWidget {
  // final String userId;
  
  const CounterStrikeScreen({super.key});

  @override
  CounterStrikeScreenState createState() => CounterStrikeScreenState();
}

class CounterStrikeScreenState extends State<CounterStrikeScreen> {
  // Map<String, dynamic>? _postData;
  
  @override
  Widget build(BuildContext context) {
    // final currentGame = Provider.of<Auth>(context).currentGame;
    const currentGame = 'CS 2';

    return Scaffold(
      appBar: AppBar(
        backgroundColor:  const Color(0xFF0D1015),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(currentGame, style: TextStyle(color: Colors.white),),
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>( // Use StreamBuilder for real-time updates
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('game', isEqualTo: currentGame) // Filter by game category
            .orderBy('timestamp', descending: true) 
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // return const Center(
            //   child: Text('Error loading posts'),
            print(snapshot.error);
            // );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;

          if (posts.isEmpty) {
            return const Center(
              child: Text('No Valorant posts yet.'),
            );
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
      ),
    );
  }

}