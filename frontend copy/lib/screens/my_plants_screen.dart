import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyPlantsScreen extends StatefulWidget {
  @override
  _MyPlantsScreenState createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen> {
  List<dynamic> myPlants = [];

  @override
  void initState() {
    super.initState();
    fetchMyPlants();
  }

  Future<void> fetchMyPlants() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');
    if (token == null) {
      // Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final url = Uri.parse('http://127.0.0.1:8000/api/user/my_plants/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        myPlants = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      print('Failed to load my plants');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Миний ургамлууд'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/add'),
          ),
        ],
      ),
      body:
          myPlants.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: myPlants.length,
                itemBuilder: (context, index) {
                  final plant = myPlants[index];
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      leading: Builder(
                        builder: (context) {
                          final base64Image = plant['plant']['image_base64'];
                          if (base64Image == null || base64Image.isEmpty) {
                            return Icon(Icons.nature);
                          }

                          try {
                            // If the string contains the prefix, remove it
                            final cleanedBase64 =
                                base64Image.contains(',')
                                    ? base64Image.split(',').last
                                    : base64Image;

                            final imageBytes = base64Decode(cleanedBase64);
                            return Image.memory(
                              imageBytes,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            );
                          } catch (e) {
                            print('Error decoding base64 image: $e');
                            return Icon(Icons.broken_image);
                          }
                        },
                      ),

                      title: Text(plant['nickname']),
                      subtitle: Text(plant['plant']['name'] ?? ''),
                      trailing: Text("💧 ${plant['last_watered'] ?? ''}"),
                    ),
                  );
                },
              ),
    );
  }
}
