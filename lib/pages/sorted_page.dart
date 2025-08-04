import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/entry_provider.dart';
import 'package:provider/provider.dart';

class SortedPage extends StatelessWidget {
  const SortedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entryProvider=Provider.of<EntryProvider>(context);
    final sortedEntries=[...entryProvider.entries]
    ..sort((a,b)=>b.priority.compareTo(a.priority));

    return Scaffold(
      appBar: AppBar(title: const Text('Sorted Entries')),
      body: sortedEntries.isEmpty
        ?const Center(child: Text('No entreis yet.'))
        :ListView.builder(
          itemCount: sortedEntries.length,
          itemBuilder: (context, index){
            final entry=sortedEntries[index];

            return Dismissible(
              key: ValueKey(entry.date.toIso8601String()),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white)
              ), 
              onDismissed: (_){
                final originalIndex=entryProvider.entries.indexOf(entry);
                entryProvider.deleteEntry(originalIndex);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Delet"${entry.title}"')),
                );
              },
              child: ListTile(
                title: Text(entry.title),
                subtitle: Text('Priority: ${entry.priority} \n${entry.date.toLocal()}'),
              ),
            );
          }
        )
    );
  }
}