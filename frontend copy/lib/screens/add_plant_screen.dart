import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddPlantPage extends StatefulWidget {
  @override
  _AddPlantPageState createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  String watering = '';
  String sunlight = '';
  String temperature = '';
  String? base64Image;
  int? categoryId;
  bool isSubmitting = false;

  List<Map<String, dynamic>> categories = [];
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final url = Uri.parse("http://127.0.0.1:8000/api/categories/");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> categoryData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      setState(() {
        categories =
            categoryData
                .map((e) => {'id': e['id'], 'name': e['name']})
                .toList();
      });
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        base64Image =
            "data:image/png;base64," + base64Encode(bytes); // ready to send
      });
    }
  }

  Future<void> submitPlant() async {
    if (!_formKey.currentState!.validate() ||
        base64Image == null ||
        categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in all fields, pick image, and select category.',
          ),
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final url = Uri.parse("http://127.0.0.1:8000/api/create_plant/");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: jsonEncode({
        "name": name,
        "description": description,
        "watering": watering,
        "sunlight": sunlight,
        "temperature": temperature,
        "image_base64": base64Image,
        "category_id": categoryId,
      }),
    );

    setState(() => isSubmitting = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      _formKey.currentState!.reset();
      setState(() {
        base64Image = null;
        categoryId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🌿 Plant added successfully!')),
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
        title: const Text("Add New Plant"),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField("Name", onChanged: (val) => name = val),
              buildTextField(
                "Description",
                onChanged: (val) => description = val,
              ),
              buildTextField("Watering", onChanged: (val) => watering = val),
              buildTextField("Sunlight", onChanged: (val) => sunlight = val),
              buildTextField(
                "Temperature",
                onChanged: (val) => temperature = val,
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: buildInputDecoration("Category"),
                value: categoryId,
                onChanged: (value) => setState(() => categoryId = value),
                items:
                    categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category['id'],
                        child: Text(category['name']),
                      );
                    }).toList(),
                validator:
                    (value) =>
                        value == null ? "Please select a category" : null,
              ),

              const SizedBox(height: 16),
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
                              base64Decode(
                                base64Image!.replaceAll(
                                  RegExp(r'^data:image\/[a-zA-Z]+;base64,'),
                                  '',
                                ),
                              ),
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
