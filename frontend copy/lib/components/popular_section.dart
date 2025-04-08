import 'package:flutter/material.dart';
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
                errorBuilder: (context, error, stackTrace) =>
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
                        child: Image.asset(
                          plant['image'],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
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
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
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
