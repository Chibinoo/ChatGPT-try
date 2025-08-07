import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/entry.dart';
import 'package:flutter_application_1/data/entry_provider.dart';
import 'package:flutter_application_1/pages/settings_page.dart';
import 'package:flutter_application_1/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class SortedPage extends StatefulWidget {
  const SortedPage({super.key});

  @override
  State<SortedPage> createState() => _SortedPageState();
}

class _SortedPageState extends State<SortedPage> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Work', 'Hobby', 'Personal', 'Other'];

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
          body: Column(
            children: [
              const SizedBox(height: 10),
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
              Expanded(
                child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Dismissible(
                      key: Key('${entry.title}-${entry.date}'),
                      background: Container(color: theme.colorScheme.error),
                      onDismissed: (_) {
                        entryProvider.deleteEntry(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${entry.title} deleted')),
                        );
                      },
                      child: ListTile(
                        title: Text(
                          entry.title,
                          style: theme.textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          'Priority:${entry.priority} | Category:${entry.category}\nDate:${entry.date.toLocal().toString().split(" ")[0]}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        tileColor: theme.cardColor,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}