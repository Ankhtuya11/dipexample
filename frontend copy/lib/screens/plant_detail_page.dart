import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PlantDetailPage extends StatefulWidget {
  final int plantId;

  const PlantDetailPage({super.key, required this.plantId});

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  Map<String, dynamic>? plant;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlant();
  }

  Future<void> fetchPlant() async {
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/plants/${widget.plantId}/',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          plant = jsonDecode(utf8.decode(response.bodyBytes));
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load plant');
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (plant == null) {
      return const Scaffold(body: Center(child: Text('Plant not found')));
    }

    String? imageBase64 = plant!['image_base64'];
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      imageBase64 = imageBase64.replaceAll(
        RegExp(r"^data:image\/[a-zA-Z]+;base64,"),
        "",
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plant!['name'] ?? 'Plant Detail'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageBase64 != null && imageBase64.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.memory(
                  base64Decode(imageBase64),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(child: Icon(Icons.local_florist, size: 50)),
              ),
            const SizedBox(height: 20),
            Text(
              plant!['name'] ?? 'Нэргүй ургамал',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _iconInfo(
                    Icons.wb_sunny,
                    "Нар",
                    plant!['sunlight'],
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _iconInfo(
                    Icons.water_drop,
                    "Усалгаа",
                    plant!['watering'],
                    Colors.blueAccent,
                  ),
                ),
                Expanded(
                  child: _iconInfo(
                    Icons.thermostat,
                    "Темп",
                    plant!['temperature'],
                    Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Тайлбар",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              plant!['description'] ?? 'Тайлбар байхгүй.',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/addplant');
              },
              icon: const Icon(Icons.add),
              label: const Text(
                "Миний ургамалд нэмэх",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconInfo(IconData icon, String label, String? value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 6),
        Text(value ?? '—', style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
