import 'package:flutter/material.dart';
import 'dart:convert'; // For base64Decode
import '../constants.dart';

class PopularSection extends StatelessWidget {
  final List<Map<String, dynamic>> plants;

  const PopularSection({required this.plants, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Алдартай',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Image.asset(
                'assets/icons/more.png',
                color: green,
                height: 20,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.more_horiz, color: green),
              ),
            ],
          ),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(top: 10),
              itemCount: plants.length,
              itemBuilder: (_, index) {
                final plant = plants[index];
                String? imageBase64 =
                    plant['image_base64']; // Assuming image is base64

                // If the image contains the data:image/png;base64, prefix, remove it
                if (imageBase64 != null && imageBase64.isNotEmpty) {
                  imageBase64 = imageBase64.replaceAll(
                    RegExp(r"^data:image\/[a-zA-Z]+;base64,"),
                    "",
                  );
                }

                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(left: 20, right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: green.withOpacity(0.1), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            imageBase64 != null && imageBase64.isNotEmpty
                                ? Image.memory(
                                  base64Decode(
                                    imageBase64,
                                  ), // Decode base64 image
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                )
                                : Image.asset(
                                  plant['image'] ??
                                      'assets/images/default_image.png', // Default image if base64 is not available
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        width: 70,
                                        height: 70,
                                        color: Colors.green.shade100,
                                        child: const Icon(Icons.local_florist),
                                      ),
                                ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          plant['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: black.withOpacity(0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 5),
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: green,
                        child: Image.asset(
                          'assets/icons/add.png',
                          color: white,
                          height: 15,
                          errorBuilder:
                              (context, error, stackTrace) => const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 15,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
