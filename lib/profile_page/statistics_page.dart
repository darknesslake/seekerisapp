import 'package:flutter/material.dart';


class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your statistics'),
      ),
      body: const Center(
        child: Text('Your statistics goes here'),
      ),
    );
  }
}

