import 'package:flutter/material.dart';
import 'package:frontend/screens/ToolkitSection.dart';
import 'package:frontend/screens/findplants.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/plant_detail.dart';
import 'package:frontend/screens/register_screen.dart';
import 'package:frontend/screens/my_plants_screen.dart';
import 'package:frontend/screens/add_plant_screen.dart';
import 'package:frontend/widgets/animated_navbar.dart'; // Make sure this widget is created

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomePage(),
    FindPlantsPage(),
    AddPlantPage(),
    MyPlantsScreen(),
    ToolkitSection(),
    LoginScreen(),
    RegisterScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plantanhaa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Gilroy'),
      home: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: AnimatedNavbar(
          selectedIndex: _currentIndex,
          onTabChange: (index) {
            setState(() => _currentIndex = index);
          },
        ),
      ),
      routes: {
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/plant_detail': (context) => PlantDetailScreen(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
