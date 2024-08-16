import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../resources/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  // final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email or Username'), 
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email or username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20,),

              ElevatedButton(
                onPressed: _isLoading ? null : () async {  // Disable button while loading
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isLoading = true); // Show loading indicator

                    try {
                      await context.read<Auth>().loginWithEmailAndPassword(
                        context, 
                        _emailController.text, 
                        _passwordController.text,
                      );
                      Navigator.pushReplacementNamed(context, '/home'); // Navigate on success
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    } finally {
                      setState(() => _isLoading = false); // Hide loading indicator
                    }
                  }
                },
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: Colors.blue, 
                //   foregroundColor: Colors.white,
                //   padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                //   textStyle: const TextStyle(fontSize: 18),
                //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)), // Add rounded corners
                // ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24, // Set width and height for the CircularProgressIndicator
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      ) // Loading indicator
                    : const Text('Login', style: TextStyle(fontSize: 18)),
              ),

              // ElevatedButton(
              //   onPressed: _isLoading ? null : () async { // Disable button when loading
              //     if (_formKey.currentState!.validate()) {
              //       setState(() {
              //         _isLoading = true; // Start loading
              //       });
              //       try {
              //         final username = _usernameController.text.trim();
              //         final password = _passwordController.text.trim();

              //         QuerySnapshot snap = await FirebaseFirestore.instance
              //             .collection("users")
              //             .where("username", isEqualTo: username.toLowerCase())
              //             .get();

              //         if (snap.docs.isNotEmpty) {
              //           final userEmail = snap.docs[0]['email'] as String;
              //           context.read<Auth>().login(userEmail, password);
              //         } else {
              //           throw Exception('No user found for that username.');
              //         }

              //         // Navigate on successful login
              //         Navigator.of(context).pushReplacementNamed('/home');
              //       } catch (e) {
              //         ScaffoldMessenger.of(context).showSnackBar(
              //           SnackBar(content: Text('Error: $e')),
              //         );
              //       } finally {
              //         setState(() {
              //           _isLoading = false; // Stop loading
              //         });
              //       }
              //     }
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.blue,  // Background color
              //     foregroundColor: Colors.white,  // Text color
              //     padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              //     textStyle: TextStyle(fontSize: 18),
              //     shape: RoundedRectangleBorder( // Rounded corners
              //       borderRadius: BorderRadius.circular(25.0), 
              //     ),
              //   ),
              //   child: _isLoading
              //       ? CircularProgressIndicator( // Loading indicator
              //           color: Colors.white,
              //         )
              //       : Text("LOG IN"),
              // ),
              
              const SizedBox(height: 10,),

              ElevatedButton(
                onPressed: () {
                    Navigator.pushNamed(context, '/register'); 
                  },
                  child: const Text('Register'),
                ),
              const SizedBox(height:10,),

              ElevatedButton(
                onPressed: () async {
                  await context.read<Auth>().signInWithGoogle();
                },
                child: const Text('Sign In with Google'),
              ),

              
              // ElevatedButton.icon(
              //   onPressed: () async {
              //     try {
              //       await Provider.of<Auth>(context, listen: false).signInWithGoogle();
              //       // Navigation after successful login
              //       Navigator.pushReplacementNamed(context, '/'); // Or any other route
              //     } catch (e) {
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         SnackBar(content: Text('Sign in with Google failed: $e')),
              //       );
              //     }
              //   },
              //   icon: const Icon(Icons.login),
              //   label: const Text('Sign In with Google'),
              // ),
            ],
          ),
        ),
      ),
    );
  }

// Future<void> _login(BuildContext context) async {
//     try {
//       final auth = Provider.of<Auth>(context, listen: false);
//       await auth.loginWithEmailAndPassword(
//         _emailController.text.trim(), 
//         _passwordController.text.trim(),
//       );
//       // Navigation after successful login
//       Navigator.pushReplacementNamed(context, '/'); 
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())), 
//       );
//     }
//   }
}
