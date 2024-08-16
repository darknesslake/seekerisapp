import 'package:flutter/material.dart';
import 'package:seekeris/games_pages/cs_screen.dart';
import 'package:seekeris/games_pages/valorant_screen.dart';

// Assuming you have these screens defined

class GamesScreen extends StatefulWidget {
  // final String userId; // User ID to display the profile for

  const GamesScreen({super.key,});

  @override
  GamesScreenState createState() => GamesScreenState();
}

class GamesScreenState extends State<GamesScreen> {
  // Store fetched user data
  // Map<String, dynamic>? _userData;
  // final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    // _fetchUserData(); // Fetch the user's profile data on initialization
  }

  // Future<void> _fetchUserData() async {
  //   try {
  //     DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(widget.userId)
  //         .get();

  //     if (userSnapshot.exists) {
  //       setState(() {
  //         _userData = userSnapshot.data() as Map<String, dynamic>;
  //       });
  //     } else {
  //       // Handle the case where the user document doesn't exist
  //       throw Exception('User not found');
  //     }
  //   } catch (e) {
  //     // Handle errors, e.g., show a SnackBar
  //     print('Error fetching user data: $e');
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    // return DefaultTabController(
    //   length: 2, // Two tabs
    //   child: Scaffold(
    //     appBar: AppBar(
    //       title: const Text('Games'),
    //       bottom: const TabBar(
    //         tabs: [
    //           Tab(text: 'VALORANT'),
    //           Tab(text: 'CS2'),
    //         ],
    //       ),
    //     ),
    //     body: const TabBarView(
    //       children: [
    //         ValorantScreen(),
    //         CounterStrikeScreen(),
    //       ],
    //     ),
    //   ),
    // );
  
  return Scaffold(
    backgroundColor:  const Color.fromARGB(255, 0, 0, 0),
    appBar: AppBar(
        backgroundColor:  const Color(0xFF0D1015),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Games',
        style: TextStyle(
                
                color: Colors.white, 
                fontFamily: 'Wittgenstein', 
                fontWeight: FontWeight.bold 
                ),),
      ),
    // child: Scaffold(
      body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: 
            
            _buildGamesMenu(context),
            // (_userData != null)
            //     ? Column( // Wrap the body content in a Column if userData is not null
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         children: [
            //           _buildGamesMenu(context),
            //           const SizedBox(height: 4),

            //         ],
            //       )
            //     : const Center(child: CircularProgressIndicator()),
          ),
        ),
      // ),
  );
  
  }

  Widget _buildGamesMenu(BuildContext context,) {
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
            _buildButton(context, 'VALORANT', const ValorantScreen()),
            _buildButton(context, 'CS 2', const CounterStrikeScreen()),
  
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String label, Widget destination) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      // icon: Icon(icon, color: Colors.white),
      label: Text(label,
          style: const TextStyle(color: Colors.white, fontFamily: 'Wittgenstein', fontWeight: FontWeight.bold, fontSize: 20)),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }

}