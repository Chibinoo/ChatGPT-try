import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/add_entry_page.dart';
import 'package:flutter_application_1/widgets/entry_list_widget.dart';
import 'package:flutter_application_1/widgets/streak_tiles_widget.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/entry.dart';
import '../data/entry_provider.dart';
import 'package:flutter_application_1/themes/theme_provider.dart';
import 'package:flutter_application_1/widgets/numbered_list_widget.dart';

//helper for dates
DateTime parseDate(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  throw ArgumentError('Unsupported date type: ${value.runtimeType}');
}

class SortedPage extends StatefulWidget {
  const SortedPage({super.key});

  @override
  State<SortedPage> createState() => _SortedPageState();
}

class _SortedPageState extends State<SortedPage> {
  String _sortOption = 'date_desc'; //default sorting
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

        //sorte based on selection
        entries.sort((a, b) {
          final dateA = parseDate(a.date);
          final dateB = parseDate(b.date);

          switch (_sortOption) {
            case 'date_asc':
              return dateA.compareTo(dateB);
            case 'priority_desc':
              return b.priority.compareTo(a.priority);
            case 'priority_asc':
              return a.priority.compareTo(b.priority);
            default:
              return dateB.compareTo(dateA); //date_desc
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: const Text('Sorted Entries', style: TextStyle(fontSize: 25)),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                StreakTilesWidget(entriesByDay: entriesByDay),
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
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                    ),
                    Text(
                      'Entries',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    /*IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => AddEntryPage()),
                        );
                      },
                    ),*/
                    const Spacer(),
                    PopupMenuButton<String>(
                      initialValue: _sortOption,
                      onSelected: (value) {
                        setState(() {
                          _sortOption = value;
                        });
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'date_desc',
                          child: Text('Newest First'),
                        ),
                        PopupMenuItem(
                          value: 'date_asc',
                          child: Text('Oldest First'),
                        ),
                        PopupMenuItem(
                          value: 'priority_desc',
                          child: Text('Highest priority'),
                        ),
                        PopupMenuItem(
                          value: 'priority_asc',
                          child: Text('Lowest priority'),
                        ),
                      ],
                    ),
                  ],
                ),
                /*Container(
                  child: entries.isEmpty
                      ? const Center(child: Text('No Entries yet'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            final date = parseDate(entry.date);

                            return Dismissible(
                              key: ValueKey(
                                entry.title + date.toIso8601String(),
                              ),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              secondaryBackground: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (direction) {
                                entryProvider.deleteEntry(index);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Deleted''${entry.title}"),
                                  ),
                                );
                              },
                              child: ListTile(
                                title: Text(entry.title),
                                subtitle: Text(
                                  "Date: ${date.toLocal().toString().split(' ')[0]}\n"
                                  "Category: ${entry.category}",
                                ),
                                trailing: Text(
                                  "Priority: ${entry.priority}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),*/
                EntryListWidget(entries: entries),
                NumberedListWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}
