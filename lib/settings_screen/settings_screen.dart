import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seekeris/settings_screen/ProfileEdition.dart';
import 'package:seekeris/settings_screen/favorite_screen.dart';
import 'package:seekeris/resources/auth.dart';
import 'package:seekeris/settings_screen/privacy_screen.dart';
import 'package:seekeris/settings_screen/activity_screen.dart';


class SettingsScreen extends StatefulWidget {
  final String? userId; // User ID to display the profile for

  const SettingsScreen({super.key, required this.userId});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  Map<String, dynamic>? _userData;  
  // final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

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


  Widget _buildSettings(BuildContext context, 
  Map<String, dynamic> userData
  ) {
    final authProvider = Provider.of<Auth>(context, listen: false);
    final currentUserId = authProvider.user?.uid; 

    return Column(
      children: [ 
        Container( // Add a Container for styling
          width: double.infinity,
          padding: const EdgeInsets.all(20.0), // Add padding
          decoration: BoxDecoration( // Add some decoration
            color: Color(0xFF0D1015), // Background color
            borderRadius: BorderRadius.circular(10.0), // Rounded corners
          ),
        // padding: const EdgeInsets.all(8.0),
      
        child:  Column( 
          crossAxisAlignment: CrossAxisAlignment
          .start,

          children: [
            _buildButton(
            context,
            'Profile Edit',
            Icons.edit_square,
            ProfileEditScreen(userData: userData),
          ),
          // const SizedBox(height: 12),

          ],),),
          const SizedBox(height: 22,),

          Container( 
            width: double.infinity,
            padding: const EdgeInsets.all(20.0), // Add padding
            decoration: BoxDecoration( // Add some decoration
              color: Color(0xFF0D1015), // Background color
              borderRadius: BorderRadius.circular(10.0), // Rounded corners
            ),
            child:  Column( 
              crossAxisAlignment: CrossAxisAlignment
              .start,

              children: [
                _buildButton(
                  context, 
                  'Activity', 
                  Icons.local_activity, 
                  ActivityScreen(
                    // userId: currentUserId
                    ), // Pass the non-null currentUserId
                ),
                const SizedBox(height: 12),

                _buildButton(context, 'Favorite', Icons.favorite, const FavoriteScreen()),
                const SizedBox(height: 12),

                _buildButton(
                  context,
                  'Privacy',
                  Icons.privacy_tip,
                  PrivacyScreen(
                    // userId: currentUserId
                    ), // Pass the non-null currentUserId
                ),
                // const SizedBox(height: 12),
              ],
            ),
          ),
          const SizedBox(height: 22,),

          Container( 
            width: double.infinity,
            padding: const EdgeInsets.all(20.0), // Add padding
            decoration: BoxDecoration( // Add some decoration
              color: Color(0xFF0D1015), // Background color
              borderRadius: BorderRadius.circular(10.0), // Rounded corners
            ),
            child:  Column( 
              crossAxisAlignment: CrossAxisAlignment
              .start,

            children: [
              ElevatedButton.icon(
                onPressed: () async {
                
              }, 
                icon: const Icon(Icons.add_box_outlined, color: Colors.white), 
                label: const Text('Add Account', style: TextStyle(color: Colors.white, fontFamily: 'Merriweather'),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              
              ElevatedButton.icon(
                  onPressed: () async {
                  Navigator.of(context).pop(); // Close the menu before logging out
                  
                },
                  icon: const Icon(Icons.logout_outlined, color: Colors.white), 
                  label: const Text('Logout', style: TextStyle(color: Colors.white, fontFamily: 'Merriweather'),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
            ],
          ),
        ),
      ],
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0D1015),
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: (_userData != null)
                ? Column( // Wrap the body content in a Column if userData is not null
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // _buildProfileHeader(context, _userData!),
                      // const SizedBox(height: 4),
                      _buildSettings(
                        context, 
                        _userData!
                      ),
                      const SizedBox(height: 4),
                      // _buildProfileContent(_userData!),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
    );
  }

}

