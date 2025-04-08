import 'package:flutter/material.dart';
import 'package:frontend/components/category_tabs.dart';
import 'package:frontend/components/featured_slider.dart';
import 'package:frontend/components/popular_section.dart';
import 'package:frontend/components/search_bar.dart';
import 'package:frontend/services.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? selectedCategoryId;
  int activePage = 0;

  PageController controller = PageController(viewportFraction: 0.6);

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> plants = [];
  List<Map<String, dynamic>> allPlants = [];
  @override
  void initState() {
    super.initState();
    fetchCategories().then((fetchedCategories) {
      setState(() {
        categories = fetchedCategories;
        selectedCategoryId = categories.isNotEmpty ? categories[0]['id'] : null;
      });
      fetchPlants().then((fetchedPlants) {
        setState(() {
          allPlants = fetchedPlants;
          filterPlants(); // Always filter based on selectedCategoryId
        });
      });
    });
  }

  void filterPlants() {
    if (selectedCategoryId == null) {
      plants = List<Map<String, dynamic>>.from(allPlants); // Show all
    } else {
      plants =
          allPlants
              .where((plant) => plant['category'] == selectedCategoryId)
              .toList();
    }
    setState(() {});
  }

  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/categories/'),
    );

    if (response.statusCode == 200) {
      // Parse the JSON response
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(
        data.map((item) => item as Map<String, dynamic>),
      );
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPlants() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/plants/'),
    );

    if (response.statusCode == 200) {
      // Parse the JSON response
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(
        data.map((item) => item as Map<String, dynamic>),
      );
    } else {
      throw Exception('Failed to load plants');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/icons/menu.png',
            errorBuilder:
                (context, error, stackTrace) => const Icon(Icons.menu),
          ),
        ),
        actions: [
          Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.only(left: 0, right: 10),
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: green.withOpacity(0.5), blurRadius: 10),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/pro.png',
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SearchBarComponent(),
            categories.isEmpty
                ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text("No categories found.")),
                )
                : CategoryTabs(
                  categories: categories,
                  selectedCategoryId: selectedCategoryId!,
                  onCategorySelected: (categoryId) {
                    setState(() {
                      selectedCategoryId = categoryId;
                      filterPlants();
                    });
                  },
                ),
            plants.isEmpty
                ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text("No plants found.")),
                )
                : FeaturedSlider(
                  plants: plants,
                  // controller: controller,
                  activePage: activePage,
                  onPageChanged: (val) {
                    setState(() {
                      activePage = val;
                    });
                  },
                ),
            if (plants.isNotEmpty) PopularSection(plants: plants),
          ],
        ),
      ),
    );
  }
}
