// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Auth with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;
  bool get isLoggedIn => user != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String? _currentGame;

  String? get currentGame => _currentGame;

  void setCurrentGame(String? game) {
    _currentGame = game;
    notifyListeners(); 
  }





Future<void> signInWithGoogle() async {
  
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      // After successful login, you can fetch or create a user document in Firestore
      // ... (add your Firestore logic here)

      final user = _auth.currentUser;

      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        // Check if the user already exists in Firestore
        if (!userDoc.exists) {
          // Create a new user document in Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'userId': user.uid, // Ensure you store the uid
            'email': user.email,
            'displayName': user.displayName,
            'profilePictureUrl': user.photoURL,
            // ... other user data you want to store
          });
        } else {
          // Update the existing user document (if needed)
          await _firestore.collection('users').doc(user.uid).update({
            'displayName': user.displayName,
            'profilePictureUrl': user.photoURL,
            // ... other fields you want to update (e.g., last login time)
          });
        }

        notifyListeners();
      } else {
        throw Exception('User is null after Google sign-in.');
      }
    } catch (e) {
      // Handle errors, e.g., by showing a SnackBar
      print('Error signing in with Google: $e');
    }
  }

Future<void> registerWithEmailAndPassword(BuildContext context, String email, String password, String username,) async {
    try {

      // 2. Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // 3. Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'password': password,
        // ...other user profile data (e.g., profilePictureUrl)
      });

      // 4. (Optional) Send email verification
      try {
        await userCredential.user?.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent. Please check your inbox.'),
          ),
        );
      } catch (e) {
        print('Error sending verification email: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending verification email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      notifyListeners(); // Notify listeners of auth state change
    } on FirebaseAuthException catch (e) {
      // 5. Handle Firebase Authentication errors
      String errorMessage = 'Registration failed.'; // Default error message

      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'The account already exists for that email.';
          break;
        // Add e specific error cases as needed
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // 6. Handle other exceptions
      print('Error during registration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Login with email and password (no username lookup)
  Future<void> loginWithEmailAndPassword(BuildContext context, String email, String password) async {
    try {
      // Attempt login
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Check if the email is verified
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email address.',
        );
      }

      // Check if the user exists in Firestore (optional, but recommended)
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (!userDoc.exists) {
        throw Exception('User not found in Firestore.');
      }

      notifyListeners(); // Notify listeners of the auth state change
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Authentication errors
      String errorMessage = 'An error occurred during login.';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided for that user.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is badly formatted.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many login attempts. Please try again later.';
          break;
        // Add other error codes as needed
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  // // Function to login user by username
  // Future<void> loginWithUsernameAndPassword(BuildContext context, String username, String password) async {
  //   try {
  //     // Find the user by username
  //     QuerySnapshot snapshot = await _firestore
  //         .collection('users')
  //         .where('username', isEqualTo: username.toLowerCase())
  //         .limit(1)
  //         .get();

  //     if (snapshot.docs.isNotEmpty) {
  //       // User found, get their email and attempt login
  //       final userEmail = snapshot.docs[0]['email'] as String;
  //       await loginWithEmailAndPassword(context, userEmail, password);
  //     } else {
  //       // Handle case where the username is not found
  //       throw Exception('No user found for that username.');
  //     }
  //   } catch (e) {
  //     // Handle errors, e.g., user not found, wrong password, etc.
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Login error: $e')),
  //     );
  //   }
  // }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }

  Future<void> repost(BuildContext context, Map<String, dynamic> originalPostData) async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser == null) {
        throw Exception('User not logged in.');
      }

      // Create a new post document with the reposted content
      await FirebaseFirestore.instance.collection('posts').add({
        'userId': currentUser.uid,
        'userName': originalPostData['userName'] ?? 'Anonymous', // Use currentUser.displayName
        'userImageUrl': currentUser.photoURL ?? '',
        'originalPostId': originalPostData['postId'],
        'originalPostUserId': originalPostData['userId'], 
        'content': originalPostData['content'],
        'timestamp': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'commentsCount': 0,
        // ... other fields as needed
      });

      // Optionally, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post reposted!')),
      );
    } on FirebaseException catch (e) {
      // Handle Firestore errors
      print('Firestore Error: ${e.code} - ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reposting: ${e.message}')),
      );
    } catch (e) {
      // Handle other exceptions
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while reposting.')),
      );
    }
  }


}


// class Auth with ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   User? get currentUser => _auth.currentUser;

//   // Stream to listen for authentication state changes
//   Stream<User?> get authStateChanges => _auth.authStateChanges();

//   bool get isLoggedIn => currentUser != null;

//   get user => null;

//   // Login with email and password
//   Future<void> loginWithEmailAndPassword(BuildContext context, String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email.trim(), // Trim whitespace
//         password: password.trim(),
//       );

//       // Check if the email is verified
//       if (userCredential.user != null && !userCredential.user!.emailVerified) {
//         throw FirebaseAuthException(
//           code: 'email-not-verified',
//           message: 'Please verify your email address.',
//         );
//       }

//       // Successful login
//       notifyListeners(); // Notify listeners of the auth state change
//       Navigator.pushReplacementNamed(context, '/home'); // Redirect to home screen
//     } on FirebaseAuthException catch (e) {
//       String errorMessage = 'An error occurred during login.';

//       switch (e.code) {
//         case 'user-not-found':
//           errorMessage = 'No user found for that email.';
//           break;
//         case 'wrong-password':
//           errorMessage = 'Wrong password provided for that user.';
//           break;
//         case 'invalid-email':
//           errorMessage = 'The email address is badly formatted.';
//           break;
//         case 'email-not-verified':
//           errorMessage = 'Please verify your email address.';
//           break;
//         // Add more cases for other Firebase Auth errors as needed
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(errorMessage),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // Register with email and password (with password hashing)
//   Future<void> registerWithEmailAndPassword(String email, String password, String username,) async {
//     try {

//       // 2. Create user in Firebase Authentication
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email.trim(),
//         password: password.trim(),
//       );

//       // 3. Create user document in Firestore
//       await _firestore.collection('users').doc(userCredential.user!.uid).set({
//         'username': username,
//         'email': email,
//         'password': password,
//         // ...other user profile data (e.g., profilePictureUrl)
//       });

//       // 4. (Optional) Send email verification
//       try {
//         await userCredential.user?.sendEmailVerification();
//         print('Verification email sent to $email');
//       } catch (e) {
//         print('Error sending verification email: $e');
//         // Handle the error, e.g., by showing a SnackBar or a dialog
//       }

//       notifyListeners(); // Notify listeners of auth state change
//     } on FirebaseAuthException catch (e) {
//       // Handle Firebase Authentication errors
//       if (e.code == 'weak-password') {
//         throw Exception('The password provided is too weak.');
//       } else if (e.code == 'email-already-in-use') {
//         throw Exception('The account already exists for that email.');
//       } else {
//         throw Exception('Registration failed: ${e.message}');
//       }
//     } catch (e) {
//       // Handle other exceptions
//       throw Exception('An unexpected error occurred: $e');
//     }
//   }

//   // Logout
//   Future<void> logout() async {
//     await _auth.signOut();
//     notifyListeners();
//   }

//   // Additional helper functions as needed (e.g., reset password, update profile)
// }
