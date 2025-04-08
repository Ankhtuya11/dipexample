import 'package:flutter/material.dart';
import 'package:frontend/components/category_tabs.dart';
import 'package:frontend/components/featured_slider.dart';
import 'package:frontend/components/popular_section.dart';
import 'package:frontend/components/search_bar.dart';
import 'package:frontend/services.dart';

import '../constants.dart';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? selectedCategoryId;
  int activePage = 0;

  PageController controller = PageController(viewportFraction: 0.6);

  List<Map<String, dynamic>> categories = [
    {'id': 1, 'name': 'All Plants'},
    {'id': 2, 'name': 'House Plants'},
    {'id': 3, 'name': 'Office Plants'},
    {'id': 4, 'name': 'Backyard Plants'},
  ];

  List<Map<String, dynamic>> allPlants = [
    {
      'id': 1,
      'name': 'Snake Plant',
      'image': 'assets/images/image1.jpg',
      'category_id': 2, // House
    },
    {
      'id': 2,
      'name': 'Peace Lily',
      'image': 'assets/images/image2.jpg',
      'category_id': 2, // House
    },
    {
      'id': 3,
      'name': 'Cactus',
      'image': 'assets/images/image3.jpg',
      'category_id': 3, // Office
    },
    {
      'id': 4,
      'name': 'Rose',
      'image': 'assets/images/image5.jpg',
      'category_id': 4, // Backyard
    },
  ];

  List<Map<String, dynamic>> plants = [];

  @override
  void initState() {
    super.initState();
    selectedCategoryId = categories[0]['id']; // default to All Plants
    filterPlants();
  }

  void filterPlants() {
    if (selectedCategoryId == 1) {
      plants = allPlants;
    } else {
      plants = allPlants
          .where((plant) => plant['category_id'] == selectedCategoryId)
          .toList();
    }
    setState(() {});
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
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.menu),
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
                errorBuilder: (context, error, stackTrace) =>
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
            plants.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text("No plants found.")),
                  )
                : FeaturedSlider(
                    plants: plants,
                    controller: controller,
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
