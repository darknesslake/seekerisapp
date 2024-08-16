import 'package:flutter/material.dart';
import 'package:seekeris/explore_page/search_screen.dart';
// import 'package:searchfield/searchfield.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int? searchCount;  // Make searchCount nullable to handle potential absence

  const CustomAppBar({super.key, required this.title, this.searchCount});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent, // Make the AppBar background transparent
      elevation: 0, // Remove shadow
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen())
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255), // White color
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Conditional search count display
          if (searchCount != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[300], // Customize the background color
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18, color: Colors.black),
                  const SizedBox(width: 4),
                  Text(
                    searchCount.toString(),
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
