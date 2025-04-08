import 'package:flutter/material.dart';
import '../constants.dart'; // Create a constants file for reusable values like colors

class SearchBarComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: white,
              border: Border.all(color: green),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: green.withOpacity(0.15), blurRadius: 10),
              ],
            ),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Хайх',
                    ),
                  ),
                ),
                Image.asset(
                  'assets/icons/search.png',
                  height: 25,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.search),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 45,
            width: 45,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: green.withOpacity(0.5), blurRadius: 10),
              ],
            ),
            child: Image.asset(
              'assets/icons/adjust.png',
              color: white,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.tune, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
