import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class AnimatedNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  AnimatedNavbar({required this.selectedIndex, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: GNav(
          rippleColor: Colors.green.shade100,
          hoverColor: Colors.green.shade100,
          gap: 8,
          activeColor: Colors.white,
          iconSize: 24,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: Duration(milliseconds: 400),
          tabBackgroundColor: Colors.green,
          color: Colors.black,
          tabs: [
            GButton(icon: Icons.home, text: 'Home'),
            GButton(icon: Icons.local_florist, text: 'My Plants'),
            GButton(icon: Icons.add, text: 'Add'),
            GButton(icon: Icons.login, text: 'Login'),
            GButton(icon: Icons.person_add, text: 'Register'),
          ],
          selectedIndex: selectedIndex,
          onTabChange: onTabChange,
        ),
      ),
    );
  }
}
