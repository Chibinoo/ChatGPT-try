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
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = Theme.of(context);
        return ValueListenableBuilder(
          valueListenable: selectedPageNotifier,
          builder: (context, selectedPage, child) {
            return NavigationBar(
              indicatorColor: theme.colorScheme.secondaryContainer,
              backgroundColor: theme.bottomNavigationBarTheme.backgroundColor, // <-- use this
              destinations: const [
                NavigationDestination(icon: Icon(Icons.edit_note_sharp), label: 'Entries'),
                NavigationDestination(icon: Icon(Icons.edit_note_sharp), label: 'Entries2'),
                NavigationDestination(icon: Icon(Icons.list), label: 'Stats'),
                NavigationDestination(icon: Icon(Icons.settings), label: 'Settings')
              ],
              onDestinationSelected: (int value) {
                setState(() {
                  selectedPageNotifier.value = value;
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