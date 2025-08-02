import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'entry_provider.dart';
import 'entry.dart';
import 'sorted_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final titleControler=TextEditingController();
    final priorityControler=TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Entries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_)=> const SortedPage()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleControler,
              decoration: const InputDecoration(labelText: 'Titel'),
            ),
            TextField(
              controller: priorityControler,
              decoration: const InputDecoration(labelText: 'Priority (number)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (){
                if (titleControler.text.isNotEmpty&&priorityControler.text.isNotEmpty){
                  Provider.of<EntryProvider>(context, listen:false).addEntry(
                    Entry(
                      title:titleControler.text, 
                      date: DateTime.now(), 
                      priority: int.parse(priorityControler.text)
                    ),
                  );
                  titleControler.clear();
                  priorityControler.clear();
                }
              }, 
              child: const Text('Add Entry'),
            ),
          ],
        ),
        ),
    );
  }
}