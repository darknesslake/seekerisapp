
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seekeris/resources/auth.dart';

class RepostWidget extends StatelessWidget {
  final Map<String, dynamic> postData; // Pass the original post data

  const RepostWidget({super.key, required this.postData});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.repeat),
      onPressed: () {
        context.read<Auth>().repost(context, postData); // Call the repost function
      },
    );
  }
}