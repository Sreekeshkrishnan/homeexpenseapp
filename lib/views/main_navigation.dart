import 'package:flutter/material.dart';
import 'home_view.dart';
import 'report_page.dart';
import 'profile_page.dart';

class MainNavigation extends StatefulWidget {
  final Map<String, dynamic> user;
  const MainNavigation({
    super.key,
    required this.user,
  });
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}
class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;
  late List<Widget> pages;
  @override
  void initState() {
    super.initState();
    pages = [
      HomePage(user: widget.user),
      ReportPage(),
      ProfilePage(user: widget.user),
    ];
  }
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Reports",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
