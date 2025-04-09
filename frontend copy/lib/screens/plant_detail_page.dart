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
    fetchPlantDetail();
  }

  Future<void> fetchPlantDetail() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/plants/${widget.plantId}/'),
    );

    if (response.statusCode == 200) {
      setState(() {
        plant = jsonDecode(utf8.decode(response.bodyBytes));
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green,
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (plant == null) {
      return const Scaffold(body: Center(child: Text("Plant not found")));
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
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              plant!['name'] ?? '',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              plant!['description'] ?? '',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            const Divider(height: 30, thickness: 1.2),
            buildInfoRow("Усалгаа", plant!['watering'] ?? '—'),
            buildInfoRow("Нарны гэрэл", plant!['sunlight'] ?? '—'),
            buildInfoRow("Температур", plant!['temperature'] ?? '—'),
            buildInfoRow("Ангилал", plant!['category']?.toString() ?? '—'),
          ],
        ),
      ),
    );
  }
}
