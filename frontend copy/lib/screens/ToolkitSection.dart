import 'package:flutter/material.dart';

class ToolkitSection extends StatelessWidget {
  const ToolkitSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tools = [
      {
        'title': 'Water Calculator',
        'icon': Icons.opacity,
        'onTap': () {
          // Navigator.push to Water Calculator Page
        },
      },
      {
        'title': 'Light Meter',
        'icon': Icons.wb_sunny,
        'onTap': () {
          // Navigator.push to Light Meter Page
        },
      },
      {
        'title': 'Planting Essentials',
        'icon': Icons.format_list_bulleted,
        'onTap': () {
          // Navigator.push to Planting Essentials List Page
        },
      },
      {
        'title': 'Find Nearby Stores',
        'icon': Icons.map_outlined,
        'onTap': () {
          // Navigator.push to Map Page
        },
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Tool Kit',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tools.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final tool = tools[index];
              return GestureDetector(
                onTap: tool['onTap'] as void Function(),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tool['icon'] as IconData,
                        size: 40,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tool['title'].toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
