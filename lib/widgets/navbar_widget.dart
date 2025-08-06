import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/notifiers.dart';
import 'package:flutter_application_1/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class NavbarWidget extends StatefulWidget {
  const NavbarWidget({super.key});

  @override
  State<NavbarWidget> createState() => _NavbarWidgetState();
}

class _NavbarWidgetState extends State<NavbarWidget> {
  int selectedIndex=0;
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier, 
      builder: (context, selectedPage, child){
        return NavigationBar(
          indicatorColor: isDark ? Colors.grey[800] : Colors.white,
          backgroundColor: isDark ? Colors.black : Colors.blueGrey,
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
      },
    );
  },
    );
  }
}