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
  int? categoryId; // selected category ID
  List<Map<String, dynamic>> categories = []; // List of categories

  final picker = ImagePicker();

  // Fetch categories from the backend
  Future<void> fetchCategories() async {
    final url = Uri.parse(
        "http://127.0.0.1:8000/api/categories/"); // Adjust URL as needed
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> categoryData =
          jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        categories = categoryData
            .map((e) => {'id': e['id'], 'name': e['name']})
            .toList();
      });
    } else {
      print('Failed to fetch categories');
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
        base64Image == null ||
        categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Fill in all fields, select an image, and choose a category')),
      );
      return;
    }
    final requestBody = {
      "name": name,
      "description": description,
      "watering": watering,
      "sunlight": sunlight,
      "temperature": temperature,
      "image_base64": base64Image,
      "category_id": categoryId,
    };

    print("Request body: ${jsonEncode(requestBody)}");
    final url =
        Uri.parse("http://127.0.0.1:8000/api/create_plant/"); // Adjust URL
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plant added successfully')),
      );
    } else {
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.statusCode}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategories(); // Fetch categories when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Plant")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Name"),
                onChanged: (value) => name = value,
                validator: (value) =>
                    value!.isEmpty ? "Enter plant name" : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Description"),
                onChanged: (value) => description = value,
                validator: (value) =>
                    value!.isEmpty ? "Enter description" : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Watering"),
                onChanged: (value) => watering = value,
                validator: (value) =>
                    value!.isEmpty ? "Enter watering schedule" : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Sunlight"),
                onChanged: (value) => sunlight = value,
                validator: (value) =>
                    value!.isEmpty ? "Enter sunlight requirement" : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Temperature"),
                onChanged: (value) => temperature = value,
                validator: (value) =>
                    value!.isEmpty ? "Enter temperature" : null,
              ),
              SizedBox(height: 10),
              // Dropdown for selecting category
              DropdownButtonFormField<int>(
                hint: Text('Select Category'),
                value: categoryId,
                onChanged: (value) {
                  setState(() {
                    categoryId = value;
                  });
                },
                items: categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category['id'],
                    child: Text(category['name']),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? "Please select a category" : null,
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: Icon(Icons.image),
                label: Text("Pick Image"),
              ),
              if (base64Image != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text("Image selected ✔️"),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitPlant,
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
