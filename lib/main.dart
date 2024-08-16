import 'dart:async';



import 'package:seekeris/screens/createpost_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seekeris/screens/error_screen.dart';
import 'package:seekeris/screens/profile_screen.dart';
// import 'dart:math';


import 'screens/login_screen.dart';
import 'screens/register_screen.dart'; // Import the RegisterPage
import 'resources/auth.dart';
import 'screens/home_screen.dart';
// import 'feed_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';  

// 
// ...


// Necessary import


Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
        await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
        );
    } on FirebaseException catch (e) {
        print("Firebase initialization error: $e");
    }

    runApp(
        // ChangeNotifierProvider(
        //     create: (context) => Auth(),
        //     child: MyApp(),
        // ),
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => Auth()),
            ChangeNotifierProvider(create: (_) => CurrentPostProvider()),
            ChangeNotifierProvider(create: (_) => CurrentUserProvider()),
            // ... other providers you may have
      ],
      child: const MyApp(),
    ),
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      title: 'Seekeris',
      theme: ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0D1015),      
          selectedItemColor: Colors.blueAccent,       
          unselectedItemColor: Colors.white,  
          selectedIconTheme: IconThemeData(size: 20),  // Change selected icon size
          unselectedIconTheme: IconThemeData(size: 22),// Change unselected icon size
          selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), 
          unselectedLabelStyle: TextStyle(fontSize: 12),
          showUnselectedLabels: false, // Show labels for unselected items
          showSelectedLabels: false,
        ),
      ),
      initialRoute: '/login', // Start on the login screen
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => Consumer<Auth>(
          builder: (context, auth, _) { // Use Consumer to access auth data
            if (auth.isLoggedIn && auth.user != null) {
              return ProfileScreen(userId: auth.user!.uid); // Pass userId here
            } else {
              // Handle the case where the user is not logged in
              return const LoginScreen(); // You can navigate to another screen if needed
            }
          },
        ),       
        // '/feed': (context) => const FeedScreen(userId: '',),
        '/home': (context) => const HomeScreen(title: 'Seekeris'),

        // Add other routes here...
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => ErrorScreen(errorMessage: 'Error: Page not found!'));
      },
    );
  }
}
