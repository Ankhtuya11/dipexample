import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'package:frontend/components/search_bar.dart';

class FindPlantsPage extends StatefulWidget {
  const FindPlantsPage({super.key});

  @override
  State<FindPlantsPage> createState() => _FindPlantsPageState();
}

class _FindPlantsPageState extends State<FindPlantsPage> {
  List<dynamic> picks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlantPicks();
  }

  Future<void> fetchPlantPicks() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/plants/'), // change if needed
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          picks = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch plant data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> categories = [
      {'label': 'Better Sleep', 'image': 'assets/images/bed.jpg'},
      {'label': 'Air-Purifying', 'image': 'assets/images/air.jpg'},
      {'label': 'Shade-Loving', 'image': 'assets/images/shade.jpg'},
    ];

    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchBarComponent(),

              Text(
                'Home Greenery',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 24),
                  itemBuilder: (_, index) {
                    final item = categories[index];
                    return Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: green, width: 2),
                              image: DecorationImage(
                                image: AssetImage(item['image']!),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: green.withOpacity(0.2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['label']!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),
              Text(
                'April Plant Picks',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                    height: 250,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: picks.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 20),
                      itemBuilder: (_, index) {
                        final plant = picks[index];
                        return Expanded(
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: white,
                              boxShadow: [
                                BoxShadow(
                                  color: black.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                    child: () {
                                      String? base64Image =
                                          plant['image_base64'];
                                      if (base64Image != null &&
                                          base64Image.isNotEmpty) {
                                        base64Image = base64Image.replaceAll(
                                          RegExp(
                                            r"^data:image\/[a-zA-Z]+;base64,",
                                          ),
                                          "",
                                        );
                                        return Image.memory(
                                          base64Decode(base64Image),
                                          height: 130,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        );
                                      } else {
                                        return Container(
                                          height: 180,
                                          width: double.infinity,
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.local_florist,
                                            size: 40,
                                            color: Colors.green,
                                          ),
                                        );
                                      }
                                    }(),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          plant['name'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        // const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.grass,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                plant['watering'] ?? 'N/A',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.wb_sunny_outlined,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              plant['temperature'] ?? 'N/A',
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
