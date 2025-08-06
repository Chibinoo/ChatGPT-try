import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/notifiers.dart';

class NavbarWidget extends StatefulWidget {
  const NavbarWidget({super.key});

  @override
  State<NavbarWidget> createState() => _NavbarWidgetState();
}

class _NavbarWidgetState extends State<NavbarWidget> {
  int selectedIndex=0;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier, 
      builder: (context, selectedPage, child){
        return NavigationBar(
          indicatorColor: Colors.white,
          backgroundColor: Colors.blueGrey,
          destinations: [
            NavigationDestination(icon: Icon(Icons.edit_note_sharp), label: 'Entries'),
            NavigationDestination(icon: Icon(Icons.list), label: 'Days'),
            NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'Stats')
          ],
          onDestinationSelected: (int value) {
            setState(() {
              selectedPageNotifier.value=value;
            });
          },
          selectedIndex: selectedPage,
        );
      }
    );
  }
}