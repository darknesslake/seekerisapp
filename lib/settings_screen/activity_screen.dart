import 'package:flutter/material.dart';


class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0D1015),
        title: const Text('Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
      ),
      backgroundColor: Colors.black,
      body: Container( // Add a Container for styling
          padding: const EdgeInsets.all(20.0), // Add padding
          decoration: BoxDecoration( // Add some decoration
            // color: Colors.black, // Background color
            borderRadius: BorderRadius.circular(10.0), // Rounded corners
          ),
          child: const Text( 
            'Hello World',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              // fontWeight: FontWeight.bold,
            ),
          ),
        ),
    );
  }
}

