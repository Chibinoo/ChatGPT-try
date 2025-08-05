import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/entry_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class SortedPage extends StatefulWidget {
  const SortedPage({super.key});

  @override
  State<SortedPage> createState() => _SortedPageState();
}

class _SortedPageState extends State<SortedPage> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final entryProvider=Provider.of<EntryProvider>(context);
    //filter by selected date if chosen
    final filterEntries=entryProvider.entries.where((entry) {
      if(selectedDate==null) return true;//show all if no filter
      return entry.date.year==selectedDate!.year&&
             entry.date.month==selectedDate!.month&&
             entry.date.day==selectedDate!.day;  
    }).toList()
    ..sort((a,b)=>b.priority.compareTo(a.priority));//sort by priority

    return Scaffold(
      appBar: AppBar(title: const Text('Sorted Entries')),
      body: Column(
        children: [
          //date filter buttons
          Container(
            color: Colors.blueGrey[200],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    selectedDate==null
                      ?"Select Date"
                      :DateFormat.yMMMd().format(selectedDate!),
                  ),
                  onPressed: () async{
                    final picked=await showDatePicker(
                      context: context, 
                      initialDate: selectedDate?? DateTime.now(),
                      firstDate: DateTime(2000), 
                      lastDate: DateTime(2100)
                    );
                    if(picked!=null){
                      setState(() =>selectedDate=picked);
                    }
                  },
                ),
                const SizedBox(width: 8),
                if(selectedDate!=null)
                OutlinedButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                  onPressed: () => setState(() =>selectedDate=null),
                ),
              ],
            ),
          ),
          //filtered entries list
          Expanded(
            child: filterEntries.isEmpty
            ?const Center(child: Text('No entries for this date'))
            :ListView.builder(
              itemCount: filterEntries.length,
              itemBuilder: (context, index){
                final entry=filterEntries[index];

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
                subtitle: Text('Priority: ${entry.priority} \n${DateFormat.yMMMd().format(entry.date)}',
                ),
              ),
            );
          },
        ),
          ),
        ],
      ),
    );
  }
}