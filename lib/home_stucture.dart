import 'package:flutter/material.dart';
import 'package:weather_app/Search.dart';
import 'package:weather_app/home_page.dart';
import 'package:weather_app/settings.dart';
class HomeStructure extends StatefulWidget {
  const HomeStructure({super.key});

  @override
  State<HomeStructure> createState() => _HomeStructureState();
}

class _HomeStructureState extends State<HomeStructure> {

  int _currentIndex = 0;
  final tabs = [
    HomePage(),
    SearchPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: tabs[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            // backgroundColor: Color(0xff512DA8),
            backgroundColor: Color(0xff1565c0),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white60,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedFontSize: 15,
            selectedIconTheme: IconThemeData(size: 30),
            iconSize: 22,
            elevation: 5,
            // showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                label: "Home",
                icon: Icon(Icons.home),
              ),
              BottomNavigationBarItem(
                label: "Search",
                icon: Icon(Icons.search),
              ),
              BottomNavigationBarItem(
                label: "Settings",
                icon: Icon(Icons.settings),
              ),
            ],
            onTap: (index){
              setState(() {
                _currentIndex = index;
              });
            },

          ),
        ),);
  }
}
