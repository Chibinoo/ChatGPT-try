import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/data/entry_provider.dart';

class EditNumberedListPage extends StatefulWidget {
  const EditNumberedListPage({super.key});

  @override
  State<EditNumberedListPage> createState() => _EditNumberedListPageState();
}

class _EditNumberedListPageState extends State<EditNumberedListPage> {
  late List<TextEditingController>_controllers;

  @override
  void initState() {
    super.initState();
    final items=Provider.of<EntryProvider>(context, listen: false).numberedItems;
    _controllers=items.map((e)=>TextEditingController(text: e)).toList();
  }
  @override
  void dispose(){
    for(var c in _controllers){
      c.dispose();
    }
    super.dispose();
  }
  void _save(){
    final provider=Provider.of<EntryProvider>(context, listen: false);
    provider.numberedItems=_controllers.map((c)=>c.text).toList();
    provider.saveNumberedItems();//implement this in your provider to persist
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Numbered List')),
      body: Container(
        constraints: const BoxConstraints(minHeight: 300), // Ensures enough space for dragging
        child: ReorderableListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (oldIndex < newIndex) newIndex -= 1;
              final c = _controllers.removeAt(oldIndex);
              _controllers.insert(newIndex, c);
            });
          },
          children: [
            for (int i = 0; i < _controllers.length; i++)
              ListTile(
                key: ValueKey('edit_$i'),
                leading: Text('${i + 1}.'),
                title: TextField(
                  controller: _controllers[i],
                  decoration: const InputDecoration(border: UnderlineInputBorder()),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _controllers.removeAt(i);
                    });
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        label: const Text('Save'),
        icon: const Icon(Icons.save),
      ),
    );
  }
}