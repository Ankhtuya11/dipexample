import 'package:flutter/material.dart';

const Color green = Color(0xFF28C76F);
const Color white = Color(0xFFFFFFFF);
const Color black = Color(0xFF000000);
const Color lightGreen = Color(0xFFE1F5E5);

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
      plants =
          allPlants
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
            searchBar(),
            categoryTabs(),
            plants.isEmpty
                ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text("No plants found.")),
                )
                : featuredSlider(),
            if (plants.isNotEmpty) popularSection(),
          ],
        ),
      ),
    );
  }

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: white,
              border: Border.all(color: green),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: green.withOpacity(0.15), blurRadius: 10),
              ],
            ),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Хайх',
                    ),
                  ),
                ),
                Image.asset(
                  'assets/icons/search.png',
                  height: 25,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(Icons.search),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 45,
            width: 45,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: green.withOpacity(0.5), blurRadius: 10),
              ],
            ),
            child: Image.asset(
              'assets/icons/adjust.png',
              color: white,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.tune, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryTabs() {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (_, index) {
          final category = categories[index];
          final bool isSelected = category['id'] == selectedCategoryId;
          return GestureDetector(
            onTap: () {
              selectedCategoryId = category['id'];
              filterPlants();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Text(
                    category['name'],
                    style: TextStyle(
                      color: isSelected ? green : black.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                  if (isSelected)
                    const CircleAvatar(radius: 3, backgroundColor: green),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget featuredSlider() {
    return SizedBox(
      height: 320,
      child: PageView.builder(
        controller: controller,
        itemCount: plants.length,
        padEnds: false,
        onPageChanged: (val) => setState(() => activePage = val),
        itemBuilder: (_, index) {
          final plant = plants[index];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            margin: EdgeInsets.only(
              left:
                  index == 0
                      ? 10
                      : 8, // Зүүн талаас зөвхөн эхний карт 10px зайтай
              right: 8,
              top: index == activePage ? 20 : 30,
              bottom: index == activePage ? 20 : 30,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: lightGreen,
                border: Border.all(color: green, width: 2),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: black.withOpacity(0.05), blurRadius: 15),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      plant['image'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: green,
                      child: Image.asset(
                        'assets/icons/add.png',
                        color: white,
                        height: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget popularSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Алдартай',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Image.asset(
                'assets/icons/more.png',
                color: green,
                height: 20,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.more_horiz, color: green),
              ),
            ],
          ),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(top: 10),
              itemCount: plants.length,
              itemBuilder: (_, index) {
                final plant = plants[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(left: 20, right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: green.withOpacity(0.1), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          plant['image'],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                width: 70,
                                height: 70,
                                color: Colors.green.shade100,
                                child: const Icon(Icons.local_florist),
                              ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          plant['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: black.withOpacity(0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 5),
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: green,
                        child: Image.asset(
                          'assets/icons/add.png',
                          color: white,
                          height: 15,
                          errorBuilder:
                              (context, error, stackTrace) => const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 15,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
