import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddPlantPage extends StatefulWidget {
  @override
  _AddPlantPageState createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  String nickname = '';
  int? selectedPlantId;
  DateTime? lastWatered;
  String? base64Image;
  bool isSubmitting = false;

  List<Map<String, dynamic>> plants = [];

  @override
  void initState() {
    super.initState();
    fetchPlants();
  }

  Future<void> fetchPlants() async {
    final url = Uri.parse("http://127.0.0.1:8000/api/plants/");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> plantData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      setState(() {
        plants =
            plantData.map((e) => {'id': e['id'], 'name': e['name']}).toList();
      });
    } else {
      print("Failed to fetch plants");
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        base64Image = "data:image/png;base64," + base64Encode(bytes);
      });
    }
  }

  Future<void> submitPlant() async {
    if (!_formKey.currentState!.validate() ||
        selectedPlantId == null ||
        base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found, please login again.')),
      );
      return;
    }

    final url = Uri.parse("http://127.0.0.1:8000/api/user/add_plant/");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "plant_id": selectedPlantId,
        "nickname": nickname,
        "last_watered": lastWatered?.toIso8601String().split('T')[0],
        "image_base64": base64Image,
      }),
    );

    setState(() => isSubmitting = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      _formKey.currentState!.reset();
      setState(() {
        base64Image = null;
        selectedPlantId = null;
        lastWatered = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🌿 Plant added to your collection!')),
      );
    } else {
      print(response.body);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${response.statusCode}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F5),
      appBar: AppBar(
        title: const Text("Add My Plant"),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField("Nickname", onChanged: (val) => nickname = val),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                decoration: buildInputDecoration("Select Plant"),
                value: selectedPlantId,
                onChanged: (value) => setState(() => selectedPlantId = value),
                items:
                    plants.map((plant) {
                      return DropdownMenuItem<int>(
                        value: plant['id'],
                        child: Text(plant['name']),
                      );
                    }).toList(),
                validator:
                    (value) => value == null ? "Please select a plant" : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lastWatered != null
                          ? "Last Watered: ${lastWatered!.toLocal().toString().split(' ')[0]}"
                          : "Pick last watered date",
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          lastWatered = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text("Choose Image"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (base64Image != null)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Stack(
                    children: [
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          image: DecorationImage(
                            image: MemoryImage(
                              base64Decode(base64Image!.split(',').last),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              base64Image = null;
                            });
                          },
                          child: const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white70,
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 30),
              isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: submitPlant,
                    child: const Text("Add Plant"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, {required Function(String) onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        decoration: buildInputDecoration(label),
        onChanged: onChanged,
        validator: (val) => val!.isEmpty ? 'Required' : null,
      ),
    );
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
