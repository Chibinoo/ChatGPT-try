import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'entry_provider.dart';
import 'entry.dart';

class SortedPage extends StatefulWidget {
  const SortedPage({super.key});

  @override
  State<SortedPage> createState() => _SortedPageState();
}

class _SortedPageState extends State<SortedPage> {
  String _selectedSort = 'priority';

  List<Entry> _sortEnteries(List<Entry> entries){
    final sorted=List<Entry>.from(entries);
    if(_selectedSort=='priority'){
      sorted.sort((a,b)=>a.priority.compareTo(b.priority));
    }else if(_selectedSort=='date'){
      sorted.sort((a,b)=>a.date.compareTo(b.date));
    }else if(_selectedSort=='titel'){
      sorted.sort((a,b)=>a.title.compareTo(b.title));
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final entries =Provider.of<EntryProvider>(context).entries;
    final sortedEnteries=_sortEnteries(entries);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sorted Entries'),
        actions: [
          DropdownButton<String>(
            value: _selectedSort,
            dropdownColor: Colors.white,
            onChanged: (value) {
              setState(() =>_selectedSort=value!);
            },
            items: const[
              DropdownMenuItem(value:'priority', child:Text('Priority')),
              DropdownMenuItem(value:'date', child:Text('Date')),
              DropdownMenuItem(value:'titel', child:Text('Titel')),
            ],
          )
        ],
      ),
      body: ListView.builder(
        itemCount: sortedEnteries.length,
        itemBuilder: (context, index) {
          final entry=sortedEnteries[index];
          return ListTile(
            title: Text(entry.title),
            subtitle: Text(
              'Date: ${entry.date.toLocal()}| Priority: ${entry.priority}'),
          );
        }
      ),
    );
  }
}