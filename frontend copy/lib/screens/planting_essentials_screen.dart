import 'package:flutter/material.dart';

class PlantingEssentialsScreen extends StatelessWidget {
  const PlantingEssentialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> essentials = [
      {
        'title': 'Хөрс',
        'description': 'Дотор ургамлын хөрс',
        'icon': Icons.landscape,
        'color': Colors.brown.shade100,
      },
      {
        'title': 'Сав',
        'description': 'Ус зайлуулах нүхтэй сав',
        'icon': Icons.landscape_outlined,
        'color': Colors.orange.shade100,
      },
      {
        'title': 'Услах сав',
        'description': 'Нарийн хошуутай услах сав',
        'icon': Icons.water_drop,
        'color': Colors.blue.shade100,
      },
      {
        'title': 'Хайч',
        'description': 'Хурц, цэвэр хайч',
        'icon': Icons.content_cut,
        'color': Colors.green.shade100,
      },
      {
        'title': 'Бордоо',
        'description': 'Тэнцвэртэй ургамлын хүнс',
        'icon': Icons.spa,
        'color': Colors.purple.shade100,
      },
      {
        'title': 'Шүршигч',
        'description': 'Чийглэгт дуртай ургамлын хувьд',
        'icon': Icons.water,
        'color': Colors.cyan.shade100,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Ургамал тарих хэрэгсэл',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ургамал арчилгааны хэрэгсэл',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Амжилттай ургамал арчилгааны тулд шаардлагатай хэрэгсэл, материал.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: essentials.length,
              itemBuilder: (context, index) {
                final item = essentials[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: item['color'],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (item['color'] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 32,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['description'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Эхлэгчдэд зориулсан зөвлөмж',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTip('Хялбар арчилгаатай ургамалаас эхэлнэ'),
                  _buildTip('Чанартай хэрэгсэл худалдаж авна - илүү удаан үргэлжлэнэ'),
                  _buildTip('Хэрэгслээ цэвэр, сайн байлгана'),
                  _buildTip('Хэрэгслээ сэрүүн, хуурай газарт хадгална'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 