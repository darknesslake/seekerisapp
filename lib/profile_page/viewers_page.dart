import 'package:flutter/material.dart';


class ProfileViews extends StatelessWidget {
  const ProfileViews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viewers',
        style: TextStyle(
                color: Colors.black, 
                fontFamily: 'Wittgenstein', 
                fontWeight: FontWeight.bold 
                ),),
      ),
      body: const Center(
        child: Text('People who have viewed your profile are displayed here'),
      ),
    );
  }
}
