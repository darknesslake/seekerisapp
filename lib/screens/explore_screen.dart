import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:seekeris/explore_page/games_screen.dart';
import 'package:seekeris/explore_page/market_screen.dart';
import 'package:seekeris/explore_page/coaching_screen.dart';
import 'package:seekeris/explore_page/search_screen.dart';


class Post {
  final String imagePath; // Store the image path
  final String title;
  final String description;

  Post({required this.imagePath, required this.title, required this.description});

  // Convenience method to create the Image widget
  Image getImage() {
    return Image.asset(imagePath);
  }
}

List<Post> allPosts = [
  Post(
    imagePath: 'assets/images/bckpost.png',
    title: 'Exploring Nature',
    description: 'Take a hike in the beautiful wilderness!',
  ),
  Post(
    imagePath: 'assets/images/bckpost.png',  // Use a different image path if you have more images
    title: 'Coding Adventures',
    description: 'Learn Flutter and build amazing apps!',
  ),
  Post(
    imagePath: 'assets/images/bckpost.png',  // Use a different image path if you have more images
    title: 'Delicious Food',
    description: 'Try this new recipe for a tasty treat!',
  ),
];



class ExploreScreen extends StatefulWidget {
  final String userId;
  
  const ExploreScreen({super.key, required this.userId});

  @override
  ExploreScreenState createState() => ExploreScreenState();
}

class ExploreScreenState extends State<ExploreScreen> {
  Map<String, dynamic>? _userData;
  
  // final int _exploreIndex = 0; // Index for the nested tabs in Explore
  // // Define your explore pages (Games, Market, Coaching)
  // final List<Widget> _exploreScreens = [
  //   const GamesScreen(),
  //   const MarketScreen(),
  //   const CoachingScreen(),
  // ];

  // final _random = Random();
  //   List<Post> _randomPosts = [];
  final TextEditingController _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    // _generateRandomPosts();
    _fetchUserData();
  }
  @override
  void dispose() {
    _searchController.dispose(); 
    super.dispose();
  }

    // void _generateRandomPosts() {
    //   allPosts.shuffle(_random);
    //   _randomPosts = allPosts.sublist(0, allPosts.length); 
    // }

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

  
// Widget _buildPostItem(Post post) {
//   return Container(
//     width: double.infinity, // Expand the container to fill the width
//     margin: const EdgeInsets.symmetric(vertical: 10),

//     child: Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
//       child: InkWell(  // For tap effect
//       onTap: () { 
//         // Handle navigation to a detailed post view
//       },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect( // For rounded image corners
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
//             child: Hero(
//                 tag: post.imagePath,
//                 child: Image.network(
//                   post.imagePath, 
//                   height: 400,
//                   width: double.infinity, // Make image fill card width
//                   fit: BoxFit.cover
//                 ),
//           ),
//       ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(post.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 Text(post.description),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//     ),
//   );
// }









//   Widget _buildImageColumn() {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.black26,
//       ),
//       child: Column(
//         children: [
//           _buildImageRow(1),
//           _buildImageRow(3),
//         ],
//       ),
//     );
//   }

  // Widget _buildDecoratedImage(int imageIndex) => Expanded(
  //   child: Container(
  //     decoration: BoxDecoration(
  //       border: Border.all(width: 10, color: Colors.black38),
  //       borderRadius: const BorderRadius.all(Radius.circular(8)),
  //     ),
  //     margin: const EdgeInsets.all(4),
  //     child: Image.asset('images/pic$imageIndex.jpg'),
  //   ),
  // );

  // Widget _buildImageRow(int imageIndex) => Row(
  //   children: [
  //     _buildDecoratedImage(imageIndex),
  //     _buildDecoratedImage(imageIndex + 1),
  //   ],
  // );


  Widget _buildExploreMenu(BuildContext context, Map<String, dynamic> userData,) {
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
            _buildButton(context, 'Games', Icons.games_outlined, const GamesScreen()),
            _buildButton(context, 'Market', Icons.shop, const MarketScreen()),
            _buildButton(context, 'Coaching', Icons.model_training, const CoachingScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
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

    Widget _buildSearchField() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      },
      child: SizedBox( 
        // height: 36, // Set your desired height here
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1015),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row( 
            children: [
              Icon(Icons.search, size: 20, color: Colors.grey),
              SizedBox(width: 8), 
              Text(
                'Search...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

        // appBar: AppBar(
        //   title: const Text('Explore'), // Title for the Explore page
        //   bottom: const TabBar(
        //     tabs: [
        //       Tab(icon: Icon(Icons.gamepad), text: 'Games'),
        //       Tab(icon: Icon(Icons.storefront), text: 'Market'),
        //       Tab(icon: Icon(Icons.sports_kabaddi), text: 'Coaching'),
        //     ],
        //   ),
        // ),
        // body: TabBarView(
        //   children: _explorePages, // Use the _explorePages list here
        // ),


      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 48,
        backgroundColor: const Color(0xFF0D1015),
        title: _buildSearchField(), 
      ),

  
      // appBar: AppBar(
      //   backgroundColor:  Color(0xFF0D1015),
      //   title: const Text('Explore',
      //   style: TextStyle(
      //           color: Colors.white, 
      //           fontFamily: 'Wittgenstein', 
      //           fontWeight: FontWeight.bold 
      //           ),),
      //   actions: [
      //       IconButton(
      //         icon: const Icon(Icons.search, color: Colors.white),
      //         onPressed: () => Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (context) => SearchScreen())
      //         ),
      //       ),
      //     ],
      // ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView( 
        child: Container(
          padding: const EdgeInsets.all(5.0),
          child: (_userData != null)
            ? Column(
            
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildExploreMenu(context, _userData!),
                
                // const SizedBox(height: 20),
                

              ],
              
            )
          : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}



