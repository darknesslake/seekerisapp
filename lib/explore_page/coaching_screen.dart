import 'package:flutter/material.dart';


class CoachingScreen extends StatelessWidget {
  const CoachingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  const Color(0xFF0D1015),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Coaching', style: TextStyle(color: Colors.white),),
      ),
      backgroundColor: Colors.black,
      body: Center( // Wrap with Center for better positioning
        child: Container( // Add a Container for styling
          padding: const EdgeInsets.all(20.0), // Add padding
          decoration: BoxDecoration( // Add some decoration
            color: Colors.lightGreen[100], // Background color
            borderRadius: BorderRadius.circular(10.0), // Rounded corners
          ),
          child: const Text( 
            'Hello World',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
