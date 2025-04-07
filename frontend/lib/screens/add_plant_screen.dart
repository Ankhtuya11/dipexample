import 'dart:io';
import 'dart:convert'; // ← Энэ мөрийг нэмэхээ мартав!
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddPlantScreen extends StatefulWidget {
  @override
  _AddPlantScreenState createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  File? _image;
  final picker = ImagePicker();
  final nicknameController = TextEditingController();
  int selectedPlantId = 0;
  List<dynamic> plantOptions = [];

  @override
  void initState() {
    super.initState();
    fetchPlantOptions();
  }

  Future<void> fetchPlantOptions() async {
    final url = Uri.parse('http://127.0.0.1:8000/api/plants/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        plantOptions = List.from(
          List<Map<String, dynamic>>.from(
            List<dynamic>.from(jsonDecode(response.body)),
          ),
        );
      });
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> uploadPlant() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');
    if (token == null || _image == null || selectedPlantId == 0) {
      Fluttertoast.showToast(msg: 'Бүх мэдээллийг бүрэн бөглөнө үү');
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:8000/api/myplants/'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['nickname'] = nicknameController.text;
    request.fields['plant_id'] = selectedPlantId.toString();
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    final response = await request.send();
    if (response.statusCode == 201) {
      Fluttertoast.showToast(msg: 'Амжилттай нэмэгдлээ');
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: 'Алдаа гарлаа');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ургамал нэмэх')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nicknameController,
              decoration: InputDecoration(labelText: 'Өөрийн нэр'),
            ),
            DropdownButtonFormField(
              decoration: InputDecoration(labelText: 'Ургамал сонгох'),
              items:
                  plantOptions.map((plant) {
                    return DropdownMenuItem(
                      child: Text(plant['name']),
                      value: plant['id'],
                    );
                  }).toList(),
              onChanged: (value) {
                selectedPlantId = value as int;
              },
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.image),
              label: Text('Зураг сонгох'),
              onPressed: pickImage,
            ),
            if (_image != null) Image.file(_image!, height: 150),
            Spacer(),
            ElevatedButton(
              onPressed: uploadPlant,
              child: Text('Нэмэх'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
