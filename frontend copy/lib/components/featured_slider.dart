import 'package:flutter/material.dart';
import 'dart:convert'; // For base64Decode
import '../constants.dart';

class FeaturedSlider extends StatelessWidget {
  final List<Map<String, dynamic>> plants;
  final PageController controller;
  final int activePage;
  final Function(int) onPageChanged;

  const FeaturedSlider({
    required this.plants,
    required this.controller,
    required this.activePage,
    required this.onPageChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: PageView.builder(
        controller: controller,
        itemCount: plants.length,
        padEnds: false,
        onPageChanged: onPageChanged,
        itemBuilder: (_, index) {
          final plant = plants[index];
          String? imageBase64 =
              plant['image_base64']; // Check if image_base64 exists

          // If the image contains the data:image/png;base64, prefix, remove it
          if (imageBase64 != null && imageBase64.isNotEmpty) {
            imageBase64 = imageBase64.replaceAll(
              RegExp(r"^data:image\/[a-zA-Z]+;base64,"),
              "",
            );
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            margin: EdgeInsets.only(
              left: index == 0 ? 10 : 8,
              right: 8,
              top: index == activePage ? 20 : 30,
              bottom: index == activePage ? 20 : 30,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: lightGreen,
                border: Border.all(color: green, width: 2),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: black.withOpacity(0.05), blurRadius: 15),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child:
                        imageBase64 != null && imageBase64.isNotEmpty
                            ? Image.memory(
                              base64Decode(imageBase64), // Decode base64 image
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                            : Image.asset(
                              'assets/images/default_image.png', // Default image if base64 is not available
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: green,
                      child: Image.asset(
                        'assets/icons/add.png',
                        color: white,
                        height: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
