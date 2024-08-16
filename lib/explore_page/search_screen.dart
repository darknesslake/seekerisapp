import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'profile_search.dart';
import '../screens/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
  }

class SearchScreenState extends State<SearchScreen> {
  // final int _feedIndex = 0;

  // final List<Widget> _feedScreens = [

  // ];
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  List<DocumentSnapshot> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose(); 
    super.dispose();
  }


  Future<void> _searchUsers() async {
    if (_searchText.isEmpty) {
      setState(() {
        _searchResults = []; // Clear results if search text is empty
      });
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: _searchText.toLowerCase())
          .where('username', isLessThan: '${_searchText.toLowerCase()}z') 
          .get();

      setState(() {
        _searchResults = querySnapshot.docs;
      });
    } catch (e) {
      // Handle errors (e.g., show a SnackBar)
      print('Error searching users: $e');
    }
  }


  // Build the search results (you'll need to implement this)



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xFF0D1015),
//         iconTheme: IconThemeData(color: Colors.white),
//         // title: const Text('Search',
//         // style: TextStyle(
//         //         color: Colors.white,
                
//         //         fontFamily: 'Wittgenstein', 
//         //         fontWeight: FontWeight.bold 
//         //         ),),
//         title: _buildSearchField(), 
//       ),
//       backgroundColor: Colors.black,
//       body: _buildSearchResults(),
      
//     );
//   }
// }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF0D1015),
        title: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchText = value;
            });
            _searchUsers(); // Trigger search on text change
          },
          decoration: const InputDecoration(
            hintText: 'Search by username...',
            hintStyle: TextStyle(color: Colors.white),
            filled: true,
            fillColor: Color(0xFF0D1015),
            border: InputBorder.none, 
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _searchResults.isEmpty 
          ? const Center(child: Text('No results found'))
          : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final userData = _searchResults[index].data() as Map<String, dynamic>;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(userData['profilePictureUrl'] ?? ''),
                  ),
                  title: Text(userData['username']),
                  subtitle: Text(userData['displayName'] ?? ''),
                  onTap: () {
                    if (userData['userId'] != null) { // Check if userId is not null
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(userId: userData['userId']),
                        ),
                      );
                    } else {
                      // Handle the case where userId is null (e.g., show an error message)
                      print('Error: userId is null');
                    }
                  },
                );
              },
            ),
    );
  }
}