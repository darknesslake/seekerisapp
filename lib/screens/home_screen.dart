import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seekeris/resources/auth.dart';
import 'package:seekeris/screens/createpost_screen.dart';


import 'feed_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
// import 'search_page.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title}); // Make title required

  final String title; 

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
 // Index for the currently selected bottom navigation item

  // Define your screen widgets (replace placeholders with your actual widgets)
  // final List<Widget> _screens = <Widget>[
  //   FeedScreen(),  // Your feed screen (e.g., posts, stories, etc.)
  //   ExploreScreen(), // Your explore screen (e.g., search, discover users)
  //   ProfileScreen(userId: Provider.of<Auth>(context).user!.uid), // Profile screen
  // ];

  @override
  Widget build(BuildContext context) {
  final authProvider = Provider.of<Auth>(context); // Get the Auth provider

    // Define the _widgetOptions list inside the build method
    final List<Widget> widgetOptions = <Widget>[
      if (authProvider.isLoggedIn && authProvider.user != null) // Check if logged in
        FeedScreen(userId: authProvider.user!.uid)
      else
        Container(),
      if (authProvider.isLoggedIn && authProvider.user != null) // Check if logged in
        ExploreScreen(userId: authProvider.user!.uid)
      else
        Container(),
      if (authProvider.isLoggedIn && authProvider.user != null) // Check if logged in
        CreatePostScreen(userId: authProvider.user!.uid)
      else
        Container(),
      if (authProvider.isLoggedIn && authProvider.user != null) // Check if logged in
        ProfileScreen(userId: authProvider.user!.uid)
      else
        Container(), // Empty container if not logged in
    ];
  
    void onItemTapped(int index) {
      // Only change tab if the user is logged in for the Profile tab
      if (index != 2 || (authProvider.isLoggedIn && authProvider.user != null)) {
        setState(() {
          _selectedIndex = index;
        });
      } else {
        // If the user is not logged in and tries to access the Profile tab, navigate to the Login screen.
        Navigator.pushNamed(context, '/login');
      }
    }
  
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      //   actions: [
      //     Consumer<Auth>(
      //       builder: (context, auth, _) {
      //         return IconButton(
      //           onPressed: () {
      //             auth.logout(); 
      //           },
      //           icon: const Icon(Icons.logout),
      //         );
      //       },
      //     ),
      //   ],
      // ),
      body: Center(
        child: widgetOptions[_selectedIndex], // Display selected page
      ),
      bottomNavigationBar: SizedBox(
        height: 56, // Set your desired height here
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.green, 
          unselectedItemColor: Colors.grey,
          // backgroundColor: Colors.red,
          onTap: onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.feed),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box, ),
              label: 'Create',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}


//     final authProvider = Provider.of<Auth>(context); 
    
//     return Scaffold(
//       // appBar: AppBar(
//       //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//       //   title: Text(widget.title),
//       //   actions: [
//       //     Consumer<Auth>(
//       //       builder: (context, auth, _) {
//       //         return IconButton(
//       //           onPressed: () {
//       //             auth.logout(); 
//       //           },
//       //           icon: const Icon(Icons.logout),
//       //         );
//       //       },
//       //     ),
//       //   ],
//       // ),
//     body: Center(
//       child: Consumer<Auth>(
//         builder: (context, auth, _) {
//           if (auth.isLoggedIn && auth.user != null) {
//             if (_selectedIndex == 2) {  // If the selected index is the Profile tab
//               return ProfileScreen(userId: auth.user!.uid);
//             } else {
//               return IndexedStack(
//                 index: _selectedIndex,
//                 children: const <Widget>[
//                   FeedScreen(),  
//                   ExploreScreen(),  
//                 ],
//               );
//             }
//           } else {
//             return const LoginScreen(); 
//           }
//         },
//       ),
//     ),

//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: (index) => setState(() => _selectedIndex = index), // Update selected index
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Feed',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.explore),
//             label: 'Explore',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }







//       //   appBar: AppBar(
//       //   title: Text(widget.title), 
//       // ),
//       body: Center(
//         child: Consumer<Auth>(
//           builder: (context, auth, _) {
//             if (auth.isLoggedIn && auth.user != null) {
//               return ProfileScreen(userId: auth.user!.uid); // Pass the userId here
//             } else {
//               // If the user is not logged in
//               return Text('Not logged in'); // Or any other relevant widget
//             }
//           },
//         ),
//       ),
        

//         bottomNavigationBar: BottomNavigationBar(
//             showSelectedLabels: false,
//             showUnselectedLabels: false,
//             // backgroundColor: Colors.blue, 
//             selectedItemColor: Colors.blueAccent, 
//             unselectedItemColor: Color(0xFFFFFDFF),
//             backgroundColor:  Color(0xFF0D1015),
                     
//             currentIndex: _currentIndex,
//             onTap: (int newIndex){
//               setState(() {
//                 _currentIndex = newIndex;
//               });
//             },


//           items: const <BottomNavigationBarItem>[
//             BottomNavigationBarItem(
//               icon: Icon(Icons.feed),
//               label: 'Feed',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.explore),
//               label: 'Explore',
//             ),
//             // BottomNavigationBarItem(
//             //   icon: Icon(Icons.search),
//             //   label: 'Search',
//             // ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person),
//               label: 'Profile',
//             ),
//           ],

//         ),

//       );
//   }
// }