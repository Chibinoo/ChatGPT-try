import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/entry.dart';
import 'package:flutter_application_1/pages/add_entry_page.dart';
import 'package:flutter_application_1/data/entry_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class EntryListWidget extends StatelessWidget {
  final List<Entry> entries;

  const EntryListWidget({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final entryProvide = Provider.of<EntryProvider>(context);
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Slidable(
          key: ValueKey('${entry.title}_${entry.date.toIso8601String()}'),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEntryPage(existingEntry: entry),
                    ),
                  );
                },
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            dismissible: DismissiblePane(
              onDismissed: () {
                entryProvide.deleteEntry(index);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Task deleted')));
              },
            ),
            children: [
              SlidableAction(
                onPressed: (_) {
                  entryProvide.deleteEntry(index);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Task deleted')));
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: ListTile(
            leading: entry.imagePath != null
                ? Image.file(File(entry.imagePath!))
                : const Icon(Icons.image_not_supported),
            title: Text(entry.title),
            subtitle: Text(
              'Priority: ${entry.priority}\n${entry.category}\n${entry.date.toLocal()}',
            ),
          ),
        );
      },
    );
  }
}
