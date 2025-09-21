import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/entry.dart';
import 'package:flutter_application_1/pages/settings_page.dart';
import 'package:flutter_application_1/themes/theme_provider.dart';
import 'package:flutter_application_1/widgets/entry_list_widget.dart';
import 'package:flutter_application_1/widgets/numbered_list_widget.dart';
import 'package:flutter_application_1/widgets/streak_tiles_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/data/entry_provider.dart';

class SortedPage2 extends StatefulWidget {
  const SortedPage2({super.key});

  @override
  State<SortedPage2> createState() => _SortedPage2State();
}

class _SortedPage2State extends State<SortedPage2> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Work',
    'Hobby',
    'Personal',
    'Other',
  ];
  Map<DateTime, bool> entriesByDay = {};
  int streakCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    final provider = Provider.of<EntryProvider>(context, listen: false);
    final entries = await provider.getAllEntries();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    //group entries by date
    Map<DateTime, bool> map = {};

    for (var entry in entries) {
      if (entry['date'] != null) {
        final date = DateTime.parse(entry['date']);
        final day = DateTime(date.year, date.month, date.day);
        map[day] = true;
      }
    }
    //calculate current streak
    int currentStreak = 0;
    DateTime cursor = today;
    while (map[cursor] == true) {
      currentStreak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    setState(() {
      entriesByDay = map;
      streakCount = currentStreak;
    });
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);
    List<Entry> entries = entryProvider.entries;
    if (_selectedCategory != 'All') {
      entries = entries.where((e) => e.category == _selectedCategory).toList();
    }
    entries.sort((a, b) => b.priority.compareTo(a.priority));

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Sorted Entries'),
            backgroundColor: theme.appBarTheme.backgroundColor,
            foregroundColor: theme.appBarTheme.foregroundColor,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                StreakTilesWidget(
                  entriesByDay: entriesByDay,
                  streakCount: streakCount,
                ),
                const SizedBox(height: 5),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = cat == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: theme.colorScheme.secondaryContainer,
                          onSelected: (_) {
                            setState(() => _selectedCategory = cat);
                          },
                          backgroundColor: theme.chipTheme.backgroundColor,
                          labelStyle: theme.chipTheme.labelStyle,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 10)),
                    Text('Entries', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                  ],
                ),
                EntryListWidget(entries: entries),
                NumberedListWidget(), // <-- Now always visible under the entry list
              ],
            ),
          ),
        );
      },
    );
  }
}
