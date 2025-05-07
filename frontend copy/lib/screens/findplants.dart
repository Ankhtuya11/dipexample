import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart'; // make sure white, black, green are defined
import 'camera_screen.dart';

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
        Uri.parse('http://127.0.0.1:8000/api/plants/'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          picks = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load plants');
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  final List<Map<String, String>> categories = [
    {'label': 'Better Sleep', 'image': 'assets/images/bed.jpeg'},
    {'label': 'Air-Purifying', 'image': 'assets/images/air.jpeg'},
    {'label': 'Shade-Loving', 'image': 'assets/images/shade.jpeg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search + Identify
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Хайх',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CameraScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera_alt, size: 20),
                    label: const Text("Тодорхойлох"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Plant Finder
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.travel_explore, color: Colors.teal),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ургамлын хайлт\nӨөрт тохирох ургамлыг сонгоно уу!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Гэрийн ногоон',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 18),
                  itemBuilder: (_, index) {
                    final item = categories[index];
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage(item['image']!),
                          backgroundColor: Colors.grey.shade200,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['label']!,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),
              Text(
                '4-р сарын ургамал',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: picks.map((plant) {
                        String? base64Image = plant['image_base64'];
                        Widget plantImage;

                        if (base64Image != null && base64Image.isNotEmpty) {
                          base64Image = base64Image.replaceAll(
                            RegExp(r'^data:image/[^;]+;base64,'),
                            '',
                          );
                          try {
                            plantImage = Image.memory(
                              base64Decode(base64Image),
                              height: 130,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          } catch (e) {
                            plantImage = Container(
                              height: 130,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.red,
                              ),
                            );
                          }
                        } else {
                          plantImage = Container(
                            height: 130,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.local_florist,
                              size: 40,
                              color: Colors.green,
                            ),
                          );
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                child: plantImage,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plant['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
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
                                            overflow: TextOverflow.ellipsis,
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
                                        Expanded(
                                          child: Text(
                                            plant['temperature'] ?? 'N/A',
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
