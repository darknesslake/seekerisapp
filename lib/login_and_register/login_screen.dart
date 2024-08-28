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
                onPressed: _isLoading ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      // Replace 'your_login_function' with your actual login function
                      await context.read<Auth>().loginWithEmailAndPassword(
                        context, 
                        _emailController.text, 
                        _passwordController.text,
                      );

                      // Navigate on successful login
                      // Navigator.pushReplacementNamed(context, '/home');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: Colors.blue,
                //   foregroundColor: Colors.white,
                //   padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                //   textStyle: const TextStyle(fontSize: 18),
                //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                // ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      ) 
                    : const Text('Login', style: TextStyle(fontSize: 18)),
              ),
              
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
