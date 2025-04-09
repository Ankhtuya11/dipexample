import 'package:flutter/material.dart';
import 'package:frontend/components/category_tabs.dart';
import 'package:frontend/components/featured_slider.dart';
import 'package:frontend/components/popular_section.dart';
import 'package:frontend/components/search_bar.dart';
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

  // ✅ This controller is used for the animated card slider
  final PageController controller = PageController(viewportFraction: 0.75);

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> plants = [];
  List<Map<String, dynamic>> allPlants = [];

  @override
  void initState() {
    super.initState();
    fetchCategories().then((fetchedCategories) {
      setState(() {
        categories = fetchedCategories;
        selectedCategoryId = 0; // Default to "All"
      });
      fetchPlants().then((fetchedPlants) {
        setState(() {
          allPlants = fetchedPlants;
          filterPlants();
        });
      });
    });
  }

  void filterPlants() {
    if (selectedCategoryId == 0 || selectedCategoryId == null) {
      plants = List<Map<String, dynamic>>.from(allPlants);
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
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      List<Map<String, dynamic>> categoryList = List<Map<String, dynamic>>.from(
        data.map((item) => item as Map<String, dynamic>),
      );
      categoryList.insert(0, {"id": 0, "name": "All"});
      return categoryList;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPlants() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/plants/'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(
        data.map((item) => item as Map<String, dynamic>),
      );
    } else {
      throw Exception('Failed to load plants');
    }
  }

  @override
  void dispose() {
    controller.dispose(); // 💧 Clean up controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: white,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset(
            'assets/icons/menu.png',
            errorBuilder: (context, error, _) => const Icon(Icons.menu),
          ),
        ),
        actions: [
          Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: green.withOpacity(0.4), blurRadius: 8),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/pro.png',
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) =>
                        const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "Hello 👋",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),

            const SizedBox(height: 16),
            SearchBarComponent(),
            const SizedBox(height: 20),
            if (categories.isEmpty)
              const Center(child: Text("No categories found."))
            else
              CategoryTabs(
                categories: categories,
                selectedCategoryId: selectedCategoryId!,
                onCategorySelected: (categoryId) {
                  setState(() {
                    selectedCategoryId = categoryId;
                    filterPlants();
                  });
                },
              ),
            const SizedBox(height: 20),
            if (plants.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("No plants found."),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FeaturedSlider(
                    plants: plants,
                    activePage: activePage,
                    onPageChanged: (val) => setState(() => activePage = val),
                  ),
                  const SizedBox(height: 30),
                  PopularSection(
                    plants: plants,
                  ), // No need to add "Алдартай" above this
                ],
              ),
          ],
        ),
      ),
    );
  }
}
